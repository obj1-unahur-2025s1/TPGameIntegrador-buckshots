import logica.*
import wollok.game.*
import arma.*
import consumibles.*
import joystick.*
import mesaCompleta.*
import player.*
import program.*
import maquina.*

object juego {
  var estoyEnPantallaInicio = false
  var estoyEligiendoDificultad = false

  var botonSeleccionadoInicio     = botonInfo
  var botonSeleccionadoDificultad = dificultadFacil

  var eligioDificil = false

  method eligioDificil() = eligioDificil
  method abrirJuego() {
    keyboard.m().onPressDo({soundProgram.cambiarMuteo()})
    soundProgram.musicaPantallaInicio()
    estoyEnPantallaInicio = true
    estoyEligiendoDificultad = false
    game.addVisual(pantallaInicio)
    game.addVisual(botonJugar)
    game.addVisual(botonInfo)

    keyboard.up().onPressDo({
      if(estoyEnPantallaInicio and not botonInfo.estoyEnUso()) {
        botonSeleccionadoInicio = botonJugar
        botonJugar.seleccionar()
        botonInfo.deseleccionar()
        sonido.seleccion()
      }
    })
    keyboard.down().onPressDo({
      if(estoyEnPantallaInicio and not botonInfo.estoyEnUso()) {
        botonSeleccionadoInicio = botonInfo
        botonInfo.seleccionar()
        botonJugar.deseleccionar()
        sonido.seleccion()
      }
    })
    keyboard.space().onPressDo({
      if(estoyEnPantallaInicio) {
        botonSeleccionadoInicio.apretar()
      } else if(estoyEligiendoDificultad) {
        self.iniciar()
      }
    })
    
    
    keyboard.left().onPressDo({
      if(estoyEligiendoDificultad) {
        eligioDificil = false
        sonido.seleccion()
      }
    })
    keyboard.right().onPressDo({
      if(estoyEligiendoDificultad) {
        eligioDificil = true
        sonido.seleccion()
      }
    })
  }

  method seleccionarDificultad() {
    estoyEnPantallaInicio = false
    estoyEligiendoDificultad = true
    game.removeVisual(botonJugar)
    game.removeVisual(botonInfo)
    game.addVisual(dificultadFacil)
    game.addVisual(dificultadDificil)
  }

  method iniciar() {
    soundProgram.quitarMusicaPantallaInicio()
    estoyEligiendoDificultad = false
    game.removeVisual(pantallaInicio)
    game.removeVisual(dificultadFacil)
    game.removeVisual(dificultadDificil)
    preparativos.inicializar()
    mesa.primerNivel()
    game.onTick(4000, "IAJugarTurno", {ia.jugarSiCorresponde()})
    game.onTick(2000, "yaGanaste", {ia.ganarSiAmerita()})
  }
}

object dificultadFacil {
  method image() = if(juego.eligioDificil()) "boton_facil.png" else "boton_facil_apretado.png"
  method position() = game.at(12, 8) 
}

object dificultadDificil {
  method image() = if(juego.eligioDificil()) "boton_dificil_apretado.png" else "boton_dificil.png"
  method position() = game.at(18, 8) 
}

object botonJugar {
  var estoySeleccionado = false

  method seleccionar() {estoySeleccionado = true}
  method deseleccionar() {estoySeleccionado = false}

  method apretar() {
    //juego.iniciar()
    juego.seleccionarDificultad()
  }

  method image() = if(estoySeleccionado) "boton_play_apretado.png" else "boton_play.png"
  method position() = game.at(15, 8)  
}

object botonInfo {
  var estoySeleccionado = true

  var estoyEnUso = false

  method seleccionar() {estoySeleccionado = true}
  method deseleccionar() {estoySeleccionado = false}

  method estoyEnUso() = estoyEnUso

  method apretar() {
    if(estoyEnUso) {
      estoyEnUso = false
      game.addVisual(pantallaInicio) 
      game.addVisual(botonJugar)
      game.addVisual(self)
      game.removeVisual(pantallaInformacion) 
    } else {
      estoyEnUso = true
      game.removeVisual(pantallaInicio)
      game.removeVisual(botonJugar)
      game.removeVisual(self)
      game.addVisual(pantallaInformacion)
    }
  }

  method position() = game.at(15, 5)
  method image() = if(estoySeleccionado) "boton_info_apretado.png" else "boton_info.png"
}

object pantallaInicio {
  method image() = "pantalla_inicioFinal.png"
  method position() = game.origin() 
}

object pantallaInformacion {
  method image() = "instrucciones2.png"
  method position() = game.origin() 
}


object preparativos {
  method inicializar() {
    jugador.iniciarInventario(
      (0 .. 7).map(
        { x => new SlotInventario(
            numeroAsignado = x,
            consumible = new SlotVacio(),
            inventarioIa = false
          ) }
      )
    )
    ia.iniciarInventario(
      (0 .. 7).map(
        { x => new SlotInventario(
            numeroAsignado = x,
            consumible = new SlotVacio(),
            inventarioIa = true
          ) }
      )
    )
    configuracion.activarTeclas()
    [mesa, escopeta, jugador, ia, efectosEstado, monitor, mostrarTurno].forEach({ x => game.addVisual(x) })
    //jugador.inventario().forEach{x=>game.addVisual(x)}
    soundProgram.musicaDeFondo()
  }
}

object configuracion {
  method activarTeclas() {
    keyboard.right().onPressDo({if(not pantallazo.estasKO()) { manejoJoystick.derecha() }})
    keyboard.left().onPressDo({if(not pantallazo.estasKO())  { manejoJoystick.izquierda() }})
    keyboard.up().onPressDo({if(not pantallazo.estasKO())    { manejoJoystick.arriba() }})
    keyboard.down().onPressDo({if(not pantallazo.estasKO())  { manejoJoystick.abajo() }})
    
    keyboard.e().onPressDo({if(not maletin.estoyEnUso() and not ia.tiempoMuerto() and not pantallazo.estasKO()) {manejoJoystick.usarEscopeta()} })
    // Automatizar el inicio de nueva ronda
    keyboard.enter().onPressDo({ jugador.usarSlotSeleccionado() })
    
    keyboard.i().onPressDo(
      { game.say(
          jugador.consumibleSeleccionado(),
          jugador.descripcionDelSeleccionado()
        ) }
    )
    
    keyboard.d().onPressDo(
      { if (slotEscopeta.seleccionada()) escopeta.disparar(jugador) }
    )
    keyboard.a().onPressDo(
      { if (slotEscopeta.seleccionada()) escopeta.dispararse(jugador) }
    )
    


    keyboard.num1().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(0)}.usar(); jugador.noPodesRobar()})
    keyboard.num2().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(1)}.usar(); jugador.noPodesRobar()})
    keyboard.num3().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(2)}.usar(); jugador.noPodesRobar()})
    keyboard.num4().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(3)}.usar(); jugador.noPodesRobar()})
    keyboard.num5().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(4)}.usar(); jugador.noPodesRobar()})
    keyboard.num6().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(5)}.usar(); jugador.noPodesRobar()})
    keyboard.num7().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(6)}.usar(); jugador.noPodesRobar()})
    keyboard.num8().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(7)}.usar(); jugador.noPodesRobar()})

    keyboard.space().onPressDo({if(maletin.estoyEnUso()) {maletin.siguienteObjeto()} })

  }
}

object pantalla {
  var finDelJuego = false

  method finDelJuego() = finDelJuego

  method final() {
    soundProgram.mutear()
    finDelJuego = true
    game.clear()
    game.addVisual(self)
    game.stop()
    cartuchosEnMesa.barrerCartuchos()
    soundProgram.quitarMusicaDeFondo()
    game.removeTickEvent("IAJugarTurno")
  }
  
  method position() = game.origin()
  
  method image() = if (jugador.muerto()) "pantalla_PERDISTE.jpg" else "pantalla_GANASTE.jpg"
}

object pantallazo {
  var estasKO = false
  method estasKO() = estasKO //
  method ponerKO() {estasKO = true}
  method sacarKO() {estasKO = false}

  method pantallaNegra() {
    self.ponerKO()
    game.addVisual(self)
    game.schedule(2000, {
      game.removeVisual(self)
      self.sacarKO()
    })
  }
  method image() = "pantallaNegro.png"
  method position() = game.origin()
}

object sonido {
  /////mesa////
  method seleccion() {
    game.sound("slotSound.mp3").play()
  }
  
  method seleccionEscopeta() {
    game.sound("recarga.mp3").play()
  }
  
  method limpiar() {
    game.sound("recarga.mp3").play()
  }
  
  ////escopeta////
  method disparo_bala_cargada() {
    game.sound("disparo_bala_cargada.mp3").play()
    
  }
  
  method disparo_bala_fogueo() {
    game.sound("disparo_bala_fogueo.mp3").play()
  }
  
  ///jugador////
  method ganarVida() {
    game.sound("ganarVida.mp3").play()
  }
  
  method perderVida() {
    game.sound("perderVida.mp3").play()
  }
  
  method desfibrilador() {
    game.sound("desfibrilador.mp3").play()
  }
  
  ////objetos/////
  method serrucho() {
    game.sound("serrucho.mp3").play()
  }
  
  method lupa() {
    game.sound("lupa.mp3").play()
  }
  
  method bebida() {
    game.sound("bebida.mp3").play()
  }
  
  method ponerEsposas() {
    game.sound("ponerEsposas.mp3").play()
  }
  
  method sigoEsposado() {
    game.sound("sigoEsposado.mp3").play()
  }
  
  method meLibero() {
    game.sound("meLibero.mp3").play()
  }
  
  method inversor() {
    game.sound("inversor.mp3").play()
  }
  
  method telefono() {
    game.sound("telefonoCortado.mp3").play()
  }
  
  method puchos() {
    game.sound("puchos.mp3").play()
  }
  
  method inyeccion() {
    game.sound("inyeccion.mp3").play()
  }
  
  method pildoraGanas() {
    game.sound("pildoraGanas.mp3").play()
  }
  
  method pildoraPerdes() {
    game.sound("pildoraPerdes.mp3").play()
  }
  
  method vendas() {
    game.sound("vendas.mp3").play()
  }

  method balas_recarga() {
    game.sound("balas_recarga.mp3").play()
  }

  method subirNivel() {
    game.sound("subirNivel.mp3").play()
  }
}

object soundProgram {
  var estoyMuteado = false

  const property musicaJuego = game.sound("General Release.wav")
  const property musicaInicio = game.sound("Blank Shell.wav")

  method musicaDeFondo() {
    musicaJuego.volume(0.05)
    musicaJuego.shouldLoop(true)
    game.schedule(500, { musicaJuego.play() })
  }
  method quitarMusicaDeFondo() {
    musicaJuego.shouldLoop(false)
    musicaJuego.pause()
  }

  method musicaPantallaInicio() {
    musicaInicio.volume(0.05)
    musicaInicio.shouldLoop(true)
    game.schedule(500, { musicaInicio.play() })
  }
  method quitarMusicaPantallaInicio() {musicaInicio.stop()}

  method cambiarMuteo() {
    if(estoyMuteado) {
      estoyMuteado = false
      self.desmutear()
    } else {
      estoyMuteado = true
      self.mutear()
    }
  }

  method mutear() {
    musicaJuego.volume(0)
    musicaInicio.volume(0)
  }
  method desmutear() {
    musicaJuego.volume(0.05)
    musicaInicio.volume(0.05)
  }
}

// Blank Shell