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
    game.onTick(2000, "navegarMenu", {navegarMenu.titilar()})
    keyboard.m().onPressDo({soundProgram.cambiarMuteo()})
    soundProgram.musicaPantallaInicio()
    estoyEnPantallaInicio = true
    estoyEligiendoDificultad = false
    game.addVisual(pantallaInicio)
    game.addVisual(botonJugar)
    game.addVisual(botonInfo)
    game.addVisual(navegarMenu) //

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


    keyboard.enter().onPressDo({
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
      } else if(botonInfo.estoyEnUso()) {
        pantallaInformacion.diapositivaAnterior()
      }
    })
    keyboard.right().onPressDo({
      if(estoyEligiendoDificultad) {
        eligioDificil = true
        sonido.seleccion()
      } else if(botonInfo.estoyEnUso()) {
        pantallaInformacion.diapositivaSiguiente()
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
    game.removeTickEvent("navegarMenu")
    soundProgram.quitarMusicaPantallaInicio()
    estoyEligiendoDificultad = false
    game.removeVisual(pantallaInicio)
    game.removeVisual(dificultadFacil)
    game.removeVisual(dificultadDificil)
    preparativos.inicializar()
    mesa.primerNivel()
    game.onTick(4000, "IAJugarTurno", {ia.jugarSiCorresponde()})
    game.onTick(2000, "yaGanaste", {ia.ganarSiAmerita()})
    game.onTick(2000, "rastreando", {rastreadorObjetos.objetosRastreados().forEach{
      x=>x.autoEliminacion()
    }})
    game.onTick(2000, "rastreando", {rastreadorObjetos.cartuchosRastreados().forEach{
      x=>x.autoEliminacion()
    }})
    game.onTick(2000, "rastreando", {rastreadorObjetos.cartuchosMuestreoRastreados().forEach{
      x=>x.autoEliminacion()
    }})
    

    game.addVisual(botonConfiguracion)
  }

  var estoyEnPausa = false
  method estoyEnPausa() = estoyEnPausa
  method pausar() {estoyEnPausa = true}
  method despausar() {estoyEnPausa = false}

  var botonElegidoPausa = botonInfoPausa
  method botonElegidoPausa() = botonElegidoPausa
  method nuevoBotonPausa(unBoton) {botonElegidoPausa = unBoton}

  method animacionEnEjecucion() {
    return
    [
    apuntaArribaBoom,
    apuntaArribaNoBoom,
    apuntaAbajoBoom,
    apuntaAbajoNoBoom,
    apuntaArribaBoomRecortada,
    apuntaArribaNoBoomRecortada,
    apuntaAbajoBoomRecortada,
    apuntaAbajoNoBoomRecortada
    ].any{x=>x.estoyEnEjecucion()}
  }

  var estoyEnGameplay = false

  method estoyEnGameplay() = estoyEnGameplay
  method empezarGameplay() {estoyEnGameplay = true}
  method terminarGameplay() {estoyEnGameplay = false}
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

object botonConfiguracion {
  var estoyEnUso = false

  method apretar() {
    if(estoyEnUso) {
      juego.despausar()
      estoyEnUso = false
      game.removeVisual(pantallaBlur)
      game.addVisual(self)

      game.removeVisual(botonMenuPausa)
      game.removeVisual(botonInfoPausa)

      self.quitarPantallaInfoSiempre()
    } else {
      juego.pausar()
      estoyEnUso = true
      game.addVisual(pantallaBlur)
      game.removeVisual(self)
      
      game.addVisual(botonMenuPausa)
      game.addVisual(botonInfoPausa)
    }
  }

  method quitarPantallaInfoSiempre() {
    if(botonInfoPausa.estoyEnUso()) {
      botonInfoPausa.apretar()
      game.removeVisual(botonInfoPausa)
      game.removeVisual(botonMenuPausa)
    }
  }

  method position() = game.at(32, 13)
  method image() = "botonConfiguracion3.png"
}

object menuConfiguracion {} // Lo hago un objeto (?  AGREGAR UN RECORDATORIO DE LA LETRA P !!!

object navegarMenu {
  method titilar() {
    if(game.hasVisual(self)) {
      game.schedule(1000, {game.removeVisual(self)})
    } else {
      game.addVisual(self)
    }
  }
  method quitarSeguro() {
    if(game.hasVisual(self)) {
      game.removeVisual(self)
    }
  }

  method position() = game.at(11, 0)
  method image() = "navegarMenu600_3.png"
}


object pantallaBlur {
  method image() = "yaPagueWindowsConMenuPausa.jpg"
  method position() = game.origin()
}

object botonMenuPausa {
  var estoySeleccionado = false

  method seleccionar() {estoySeleccionado = true}
  method deseleccionar() {estoySeleccionado = false}
  
  method apretar() { // Chequear que cierre y reinicie TODO
    ia.desesposar()
    jugador.desesposar()
    juego.terminarGameplay()
    game.clear()
    
    ia.menu()
    jugador.menu()
    escopeta.menu()
    cartuchosEnMesa.barrerCartuchos()
    objetoEspejo.imagen("vacio.png")

    juego.abrirJuego()
  }


  method position() = game.at(15, 9)
  method image() = if(estoySeleccionado) "botonMenuSeleccionado.png" else "botonMenu.png"
}

object botonInfoPausa{
  var estoySeleccionado = true

  var estoyEnUso = false

  method seleccionar() {
    estoySeleccionado = true
  }
  method deseleccionar() {estoySeleccionado = false}

  method estoyEnUso() = estoyEnUso

  method apretar() {
    if(estoyEnUso) {
      estoyEnUso = false

      game.addVisual(botonMenuPausa)
      game.addVisual(self)
      game.removeVisual(pantallaInformacion) 

      
    } else {
      estoyEnUso = true

      game.removeVisual(botonMenuPausa)
      game.removeVisual(self)
      game.addVisual(pantallaInformacion)
    }
  }

  method position() = game.at(15, 6)
  method image() = if(estoySeleccionado) "botonInfoSeleccionado2.png" else "boton_info.png"
}

object pantallaInicio {
  method image() = "pantalla_inicioFinal.png"
  method position() = game.origin() 
}

object pantallaInformacion {
  var numeroDiapositiva = 0
  const diapositivas = [
    "diapositiva_1.png",
    "diapositiva_2.png",
    "diapositiva_3.png",
    "diapositiva_4.png",
    "diapositiva_5.png",
    "diapositiva_6.png",
    "diapositiva_7.png",
    "diapositiva_8.png",
    "diapositiva_9.png",
    "diapositiva_10.png",
    "diapositiva_11.png",
    "diapositiva_12.png"
  ]
  
  method diapositivaActual() = diapositivas.get(numeroDiapositiva)
  method diapositivaSiguiente() {
    if((diapositivas.size() - 1) == numeroDiapositiva) {
      numeroDiapositiva = 0
    } else {
      numeroDiapositiva += 1
    }
  }
  method diapositivaAnterior() {
    if(numeroDiapositiva == 0) {
      numeroDiapositiva = diapositivas.size() - 1
    } else {
      numeroDiapositiva -= 1
    }
  }

  method image() = self.diapositivaActual()
  method position() = game.origin() 
}

object pantallaControles {
  method mostrar() {
    if(game.hasVisual(self)) {
      game.removeVisual(self)
    } else {
      game.addVisual(self)
    }
  }

  method image() = "modoInformacionListo2.png"
  method position() = game.origin()
}

object recordatorioTeclas {
  method imagen() {
    return
    if(maletin.estoyEnUso())
      "informacionMaletin2.png"
    else if(!slotEscopeta.seleccionada() and monitor.turnoDe() == jugador)
      "informacionEscopeta2.png"
    else "vacio.png"
  }

  method mostrarSeguro() {
    if(!game.hasVisual(self)) {
      game.addVisual(self)
    }
  }

  method image() = self.imagen()
  method position() = game.origin()
}

object recordatorioAdrenalina {
  method imagen() = "informacionAdrenalina.png"

  method image() = self.imagen()
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
    [
    mesa,
    escopeta,
    jugador,
    ia,
    efectosEstado,
    monitor,
    mostrarTurno,
    objetoEspejo
    ].forEach({ x => if(not game.hasVisual(x)) {game.addVisual(x)} })
    //jugador.inventario().forEach{x=>game.addVisual(x)}
    soundProgram.musicaDeFondo()
  }
}

object configuracion {
  method activarTeclas() {
    keyboard.right().onPressDo({
      if(not pantallazo.estasKO() and !juego.estoyEnPausa()) {
        manejoJoystick.derecha()
      } else if(botonInfoPausa.estoyEnUso()) {
        pantallaInformacion.diapositivaSiguiente()
      }
    })

    keyboard.left().onPressDo({
      if(not pantallazo.estasKO() and !juego.estoyEnPausa()) {
        manejoJoystick.izquierda()
      } else if(botonInfoPausa.estoyEnUso()) {
        pantallaInformacion.diapositivaAnterior()
      }
    })
    
    keyboard.up().onPressDo({
      if(not pantallazo.estasKO() and !juego.estoyEnPausa()) {
        manejoJoystick.arriba()
      } else if(juego.estoyEnPausa() and !botonInfoPausa.estoyEnUso()) {
        botonMenuPausa.seleccionar()
        botonInfoPausa.deseleccionar()
        juego.nuevoBotonPausa(botonMenuPausa)
      }
    })

    keyboard.down().onPressDo({
      if(not pantallazo.estasKO() and !juego.estoyEnPausa()) {
        manejoJoystick.abajo()
      } else if(juego.estoyEnPausa() and !botonInfoPausa.estoyEnUso()) {
        botonInfoPausa.seleccionar()
        botonMenuPausa.deseleccionar()
        juego.nuevoBotonPausa(botonInfoPausa)
      }
    })
    
    keyboard.e().onPressDo({
      if(not maletin.estoyEnUso() and not ia.tiempoMuerto() and not pantallazo.estasKO() and !juego.estoyEnPausa()) {
        manejoJoystick.usarEscopeta()
      }
    })
    // Automatizar el inicio de nueva ronda
    keyboard.enter().onPressDo({
      if(!juego.estoyEnPausa()) {
        jugador.usarSlotSeleccionado()
        textoConsumible.imagen("vacio.png")
      } else {
        juego.botonElegidoPausa().apretar()
      }
      if(game.hasVisual(recordatorioAdrenalina)) {
        game.removeVisual(recordatorioAdrenalina)
      }
      })
    
    keyboard.i().onPressDo({
      if(not pantallazo.estasKO() and not juego.estoyEnPausa()) {
        pantallaControles.mostrar()
      }
    })
    
    keyboard.d().onPressDo(
      { if (slotEscopeta.seleccionada() and !juego.estoyEnPausa()) {
        escopeta.dispararArriba(jugador)
        slotEscopeta.deseleccionar()
        // manejoJoystick.quitarEscopetaSegura()
        }
      }
    )
    keyboard.a().onPressDo(
      { if (slotEscopeta.seleccionada() and !juego.estoyEnPausa()) {
        escopeta.dispararAbajo(jugador)
        slotEscopeta.deseleccionar()
        // manejoJoystick.quitarEscopetaSegura()
        }
      }
    )
    
    keyboard.q().onPressDo({mesa.nuevaRonda()})

    keyboard.num1().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(0)}.usar(); jugador.noPodesRobar()})
    keyboard.num2().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(1)}.usar(); jugador.noPodesRobar()})
    keyboard.num3().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(2)}.usar(); jugador.noPodesRobar()})
    keyboard.num4().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(3)}.usar(); jugador.noPodesRobar()})
    keyboard.num5().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(4)}.usar(); jugador.noPodesRobar()})
    keyboard.num6().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(5)}.usar(); jugador.noPodesRobar()})
    keyboard.num7().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(6)}.usar(); jugador.noPodesRobar()})
    keyboard.num8().onPressDo({if(jugador.puedeRobar()) {ia.inventario().get(7)}.usar(); jugador.noPodesRobar()})

    keyboard.space().onPressDo({
      if(maletin.estoyEnUso() and !juego.estoyEnPausa()) {
        maletin.siguienteObjetoSiHay()
      }
    })

    keyboard.p().onPressDo({botonConfiguracion.apretar()}) //
  }
}

object pantalla {
  var finDelJuego = false

  method finDelJuego() = finDelJuego

  method final() {
    juego.terminarGameplay()
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
  method image() = "pantallaNEGRA.png"
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
    game.sound("disparo_bala_cargada_2.mp3").play()
    
  }
  
  method disparo_bala_fogueo() {
    game.sound("disparo_bala_fogueo_2.mp3").play()
  }
  
  ///jugador////
  method ganarVida() {
    game.sound("ganarVida_2.mp3").play()
  }
  
  method perderVida() {
    game.sound("perderVida_2.mp3").play()
  }
  
  method desfibrilador() {
    game.sound("desfibrilador_2.mp3").play()
  }
  
  ////objetos/////
  method serrucho() {
    game.sound("serrucho_2.mp3").play()
  }
  
  method lupa() {
    game.sound("lupa.mp3").play()
  }
  
  method bebida() {
    game.sound("bebida.mp3").play()
  }
  
  method ponerEsposas() {
    game.sound("ponerEsposas_2.mp3").play()
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
    musicaJuego.volume(0.50) //
    musicaJuego.shouldLoop(true)
    game.schedule(500, { musicaJuego.play() })
  }
  method quitarMusicaDeFondo() {
    musicaJuego.shouldLoop(false)
    musicaJuego.pause()
  }

  method musicaPantallaInicio() {
    // musicaInicio.volume(0.05)
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