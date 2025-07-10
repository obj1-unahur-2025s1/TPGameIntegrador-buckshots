import consumir.*
import arma.*
import mesaCompleta.*
import juego.*
import player.*
import logica.*

object ia {
  var topeVidas = 4
  var contadorMuertes = 0
  var property objetos = []
  var property vidas = 0
  var estaEsposado = false

  var perdiUnTurno = false
  method perdiUnTurno() = perdiUnTurno

  const property deVerdad = #{}
  const property deFogueo = #{}
  var property cantVerdad = 0
  var property cantFogueo = 0

  method nuevoTopeVidas(nuevoTope) {topeVidas = nuevoTope}

  method restarUnaVerdad() {cantVerdad = (cantVerdad - 1).max(0)}
  method restarUnaFogueo() {cantFogueo = (cantFogueo - 1).max(0)}

  method sumarUnaFogueo() {cantFogueo = (cantFogueo + 1)}
  method sumarUnaVerdad() {cantVerdad = (cantVerdad + 1)}

  method posicionesQueSe() {
    var lasSe = #{}
    lasSe.addAll(deVerdad)
    lasSe.addAll(deFogueo)
    return
    lasSe
  }

  method estaLaSe() = self.posicionesQueSe().contains(mesa.nroCartuchoActual())
  method estaPega() = self.deVerdad().contains(mesa.nroCartuchoActual())
  method estaNoPega() = self.deFogueo().contains(mesa.nroCartuchoActual())

  method pocaDiferencia() = cantVerdad.between(cantFogueo - 1, cantFogueo + 1)

  method muerto() = vidas == 0

  method estaEsposado() = estaEsposado
  method esposar() {estaEsposado = true}
  method desesposar() {estaEsposado = false}

  method perderUnTurno() {perdiUnTurno = true}
  method liberarse() {perdiUnTurno = false}

  method nuevaDeVerdad(unaPosicion) {deVerdad.add(unaPosicion)}
  method nuevaDeFogueo(unaPosicion) {deFogueo.add(unaPosicion)}
  
  method nombre() = "Entidad"
  
  method nuevaRonda() {
    deVerdad.clear()
    deFogueo.clear()
    cantVerdad = escopeta.cargador().count( {x => x} )
    cantFogueo = escopeta.cantCartuchos() - cantVerdad
    self.nuevosConsumibles(mesa.nroCartuchoTotales().div(2))

  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


  const property inventario = []

  method vaciarInventario() {inventario.forEach( {x => x.limpiar()} )}

  method iniciarInventario(listaSlots) {
    inventario.addAll(listaSlots)
  }

  method hay(unConsumible) = inventario.any( {x => x.consumible().tipoConsumible() == unConsumible} ) // codigo ya no es, cambia a: "tipoConsumible()"

  method usar(unConsumible) {
    if(self.hay(unConsumible)){
      self.todosLos(unConsumible).first().usar()
    }
  }

  method todosLos(unConsumible) = inventario.filter( {x => x.consumible().tipoConsumible() == unConsumible} ) // Requiere una referencia

  method cantConsumibles(unConsumible) = inventario.count( {x => x.consumible().tipoConsumible() == unConsumible} ) // Requiere una referencia


  method nuevosConsumibles(unaCant) {
    (1 .. unaCant).forEach{x =>
      if(self.hayEspacio()) {
        self.nuevoConsumible()
      } 
    }
  }

  method nuevoConsumible() {
    var consumibleRandom = mesa.randomReadyObject()
    rastreadorObjetos.rastrearConsumible(consumibleRandom)
    var slotElegido = self.unSlotVacio()
    slotElegido.colocar(consumibleRandom)
    consumibleRandom.nuevaPosicion(slotElegido.position())
    maletinIA.nuevoObjeto(consumibleRandom)
  }
  method unSlotVacio() = inventario.find( {x => x.consumible().tipoConsumible() == "SlotVacio"} )

  // Inicializo una constante con una instancia de clase x
  // La guardo en un SlotInventario
  // La busco en el inventario
  // Le actualizo la posición

  // method usarSlotSeleccionado() {inventario.get(slotSeleccionado).usar()}

  method hayEspacio() = 0 < self.espaciosDisponibles() 

  method espaciosDisponibles() = inventario.count{x=>x.consumible().tipoConsumible() == "SlotVacio"}

  // method slotActual() = inventario.get(slotSeleccionado)

  // method consumibleSeleccionado() = self.slotActual().consumible()

  // method descripcionDelSeleccionado() = self.consumibleSeleccionado().descripcion()


  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  method sumarVida(unValor) {
    vidas = (vidas + unValor).min(topeVidas)
    sonido.ganarVida()
  }

  method quitarVida(unValor, delay) {
    game.schedule(delay, {
      vidas = (vidas - unValor).max(0)
      sonido.perderVida()
      self.subirNivelSiNecesario()
    })
  }
  method subirNivelSiNecesario() {
    if(vidas == 0 and contadorMuertes < 3) {
      contadorMuertes += 1
      mesa.subirNivel(contadorMuertes + 1)
    }
  }
  method ganarSiAmerita() {
    if(contadorMuertes == 3) {
      pantalla.final()
    }
  }

  method primerNivel() {
    if(juego.eligioDificil()) {
      self.nuevoTopeVidas(mesa.umbralVida())
    } else {
      self.nuevoTopeVidas(2) //
    }
    self.sumarVida(4)
  }

  method subirNivel() {
    if(juego.eligioDificil()) {
      self.nuevoTopeVidas(mesa.umbralVida())
    } else {
      self.nuevoTopeVidas(2) //
    }
    self.sumarVida(4)
  }
  method limpiarObjetos() {inventario.forEach{x=>x.limpiar()}}

  method recibirDisparo(unDaño) {
    self.quitarVida(unDaño, 4000)
  }


  method jugarSiCorresponde() {
    if(self.meCorresponde()) {
      self.empeceEjecucion()
      self.jugarTurno()
    }
  }

  method meCorresponde() {
    return
    monitor.turnoDe() == self and not maletin.estoyEnUso() and not self.estoyEjecutando() and not escopeta.sinBalas() and not mesa.pausaDeNuevoNivel() and not pantalla.finDelJuego() and not juego.estoyEnPausa() and not juego.animacionEnEjecucion()
  }



  var estoyEjecutando = false

  method estoyEjecutando() = estoyEjecutando
  method empeceEjecucion() {estoyEjecutando = true}
  method termineEjecucion() {estoyEjecutando = false}

  var tiempoMuerto = false

  method tiempoMuerto() = tiempoMuerto

  method empezarTiempoMuerto() {tiempoMuerto = true}
  method terminarTiempoMuerto() {tiempoMuerto = false}

  method jugarTurno() {
    
    if(self.estaEsposado()) {
      self.empezarTiempoMuerto()
      monitor.cambiarTurno()
      game.schedule(5000, {
        sonido.sigoEsposado()
        self.desesposar()
        self.terminarTiempoMuerto()
      })
    } else if(perdiUnTurno) {
      game.schedule(5000, {
        sonido.meLibero()
        self.liberarse()
        self.usarObjetos()
        
      })
      game.schedule(7000, {self.ejecutarMejorAccionSiCorresponde()})
    } else {
      game.schedule(2000, {
        self.usarObjetos()
        
      })
      game.schedule(6000, {
        self.ejecutarMejorAccionSiCorresponde()
      })
    }
  }


  method usarObjetos() {consumision.ejecutar()}

  method fullVida() = vidas == 4

  const estrategias = [
    new TiroSeguro(valor = 5),
    new Default(valor = 1)
  ]

  method mejorAccion() = estrategias.max{x=>x.valor()}

  method ejecutarMejorAccionSiCorresponde() {
    self.termineEjecucion()
    if(self.meCorresponde()) {
      self.ejecutarMejorAccion()
    }
  }

  method ejecutarMejorAccion() {self.mejorAccion().ejecutar()}

  method menu() {
    self.limpiarObjetos()
    inventario.clear()
    vidas = 0
  }
  

  method tengoConsumible(unConsumible) = inventario.any{x=>x.consumible() == unConsumible}


  method image() {
    return
    if(vidas == 4) "contador4.png"
    else if(vidas == 3) "contador3.png"
    else if(vidas == 2) "contador2.png"
    else if(vidas == 1) "contador1.png"
    else "contador0.png"
  }

  method position() = game.at(27, 10)
}

/*
object ia {
  const jugadas = #{seLaPosicion}
  
  method mejorJugada() = jugadas.max({ x => x.valorEstrategico() })
  
  method jugarLaMejor() = self.mejorJugada().hacerJugada()
}

object seLaPosicion {
  method valorEstrategico() {
    if (self.seLaPosicion()) {
      return 5
    } else {
      return 0
    }
  }
  
  method seLaPosicion() = self.esDeVerdad() or self.esDeFogueo()
  
  method esDeVerdad() = maquina.deVerdad().contains(mesa.nroRondaActual())
  
  method esDeFogueo() = maquina.deFogueo().contains(mesa.nroRondaActual())
  
  method hacerJugada() {
    if (self.esDeVerdad()) {
      maquina.usarObjeto(cerrucho)
      escopeta.disparar(jugador)
    } else {
      self.hacerJugada2()
    }
  }
  
  method hacerJugada2() {
    if (maquina.tiene(inversor)) {
      maquina.usarObjeto(inversor)
      maquina.usarObjeto(cerrucho)
      escopeta.disparar(jugador)
    } else {
      escopeta.disparar(self)
      ia.jugarLaMejor()
    }
  }
}

object tiroSeguro {
  method valorEstrategico() {
    if (self.hayTiroSeguro()) {
      return 4
    } else {
      return 0
    }
  }
  
  method hayTiroSeguro() = maquina.hay([lupa, inversor])
  
  method hacerJugada() {
    lupa.usar()
    if (escopeta.ronda.first()) {
      maquina.usarObjeto(inversor)
      maquina.usarObjeto(cerrucho)
      escopeta.disparar(jugador)
    } else {
      escopeta.disparar(self)
      ia.jugarLaMejor()
    }
  }
}
*/