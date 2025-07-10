import logica.*
import mesaCompleta.*
import consumibles.*
import player.*
import joystick.*
import juego.*
import maquina.*

object escopeta {
  var daño = 1
  const cargador = []

  method mostrarRecamara() {
    game.addVisual(recamara)
    game.schedule(2000, {game.removeVisual(recamara)})
  }

  method cargador() = cargador
  method cantCartuchos() = cargador.size()
  method sinBalas() = self.cargador().isEmpty()
  method recamara() = cargador.head()
  
  method daño() = daño
  method duplicarDaño() {
    daño = 2
  }
  method restablecerDaño() {
    daño = 1
  }
  
  method invertirBala() {
    const nuevoCartucho = !self.recamara()
    self.vaciarRecamara()
    self.agregarARecamara(nuevoCartucho)
    if(self.recamara()) {ia.sumarUnaFogueo()}
    else {ia.sumarUnaVerdad()}
    mesa.anteriorNro()
  }
  method vaciarRecamara() {
    

    if(self.recamara()) {ia.restarUnaVerdad()}
    else {ia.restarUnaFogueo()}
    cargador.remove(cargador.head())
    mesa.siguienteNro()
  }
  method agregarARecamara(nuevoCartucho) {
    const cargadorDadoVuelta = cargador.reverse()
    cargadorDadoVuelta.add(nuevoCartucho)
    cargador.clear()
    cargador.addAll(cargadorDadoVuelta.reverse())
  }

  method falsearRecamara() {
    self.vaciarRecamara()
    self.agregarARecamara(false)
  }

  method cartuchoEnPosicion(unaPosicion) = cargador.get(unaPosicion)
  
  method cargador(unCartucho) {
    cargador.add(unCartucho)
  }
  
  method nuevoCartuchoRandom() {
    self.cargador(mesa.probabilidad(0.5))
  }
  
  method intercambiarBala(unValor) { 
    cargador.remove(unValor)
    cargador.add(not unValor)
  } // Coloca una bala opuesta al final cuando todas son iguales
  
  method todasIguales() = self.cargador().all({ x => x == self.cargador().head() })
  
  method equilibrarArma() {
    if (self.todasIguales()) self.intercambiarBala(self.recamara())
  }
  
  method nuevoCargador(cartuchos) {
    cargador.clear() //
    cargador.addAll(cartuchos)
  }
  

  method dispararArriba(unJugador) {
    if((self.recamara() and daño == 1)) {
      apuntaArribaBoom.itsTimeForTheDurabilityTest()
      self.aQuienDisparoSiApuntoArriba(unJugador)
    } else if(!self.recamara() and daño == 1) {
      apuntaArribaNoBoom.itsTimeForTheDurabilityTest()
      self.aQuienDisparoSiApuntoArriba(unJugador)
    } else if(self.recamara() and daño == 2) {
      apuntaArribaBoomRecortada.itsTimeForTheDurabilityTest()
      self.aQuienDisparoSiApuntoArriba(unJugador)
    } else if(!self.recamara() and daño == 2) {
      apuntaArribaNoBoomRecortada.itsTimeForTheDurabilityTest()
      self.aQuienDisparoSiApuntoArriba(unJugador)
    }
  }

  method dispararAbajo(unJugador) {
    if((self.recamara() and daño == 1)) {
      apuntaAbajoBoom.itsTimeForTheDurabilityTest()
      self.aQuienDisparoSiApuntoAbajo(unJugador)
    } else if(!self.recamara() and daño == 1) {
      apuntaAbajoNoBoom.itsTimeForTheDurabilityTest()
      self.aQuienDisparoSiApuntoAbajo(unJugador)
    } else if(self.recamara() and daño == 2) {
      apuntaAbajoBoomRecortada.itsTimeForTheDurabilityTest()
      self.aQuienDisparoSiApuntoAbajo(unJugador)
    } else if(!self.recamara() and daño == 2) {
      apuntaAbajoNoBoomRecortada.itsTimeForTheDurabilityTest()
      self.aQuienDisparoSiApuntoAbajo(unJugador)
    }
  }

  method aQuienDisparoSiApuntoArriba(unJugador) {
    if(unJugador == jugador) {
      game.schedule(3000, {self.disparar(jugador)})
    } else {
      game.schedule(3000, {self.dispararse(ia)})
    }
  }

  method aQuienDisparoSiApuntoAbajo(unJugador) {
    if(unJugador == jugador) {
      game.schedule(3000, {self.dispararse(jugador)})
    } else {
      game.schedule(3000, {self.disparar(ia)})
    }
  }


  method disparar(unJugador) {
    // Todo lo referente a disparar
    if(self.recamara()) {
      sonido.disparo_bala_cargada()
      game.schedule(1000, {sonido.desfibrilador()})
      self.apuntarAlOtro(unJugador).recibirDisparo(daño)
    } else {
      sonido.disparo_bala_fogueo()
    }
  
    self.añadirCartuchoUsadoAMesa(self.recamara())

    self.vaciarRecamara()
    self.restablecerDaño()

    mesa.finDelJuego()
    self.nuevaRondaSiNecesario()

    monitor.cambiarTurno()
    monitor.turnoDe().jugarSiCorresponde()
    slotEscopeta.deseleccionar()
    mesa.nroCartuchoActual() //
  }

  method apuntarAlOtro(unJugador) = mesa.jugadores().difference([unJugador]).asList().get(0)

  method dispararse(unJugador) {
    if(self.recamara()) {
      sonido.disparo_bala_cargada()
      game.schedule(1000, {sonido.desfibrilador()})
      unJugador.recibirDisparo(daño)
      monitor.cambiarTurno()
      monitor.turnoDe().jugarSiCorresponde()
    } else {
      sonido.disparo_bala_fogueo()
      game.schedule(4000, {monitor.turnoDe().jugarSiCorresponde()})
    }

    self.añadirCartuchoUsadoAMesa(self.recamara())

    self.vaciarRecamara()
    self.restablecerDaño()

    mesa.finDelJuego()
    self.nuevaRondaSiNecesario()
    slotEscopeta.deseleccionar()
    mesa.nroCartuchoActual() //
    //turno.cambiarTurno()
    //turno.turnoDe().jugarTurno()
  }
  method nuevaRondaSiNecesario() {
    if(self.sinBalas() and not mesa.alguienMurio()) {game.schedule(3000, {mesa.nuevaRonda()})}
    // game.say(self, self.info())
  } //

  method añadirCartuchoActivoAMesa(siDispara) {new CartuchoSueltoActivo(dispara = siDispara, nro = [0,1].anyOne())}
  method añadirCartuchoUsadoAMesa(siDispara) {new CartuchoSueltoUsado(dispara = siDispara, nro = [0,1].anyOne())}


  method menu() {
    cargador.clear()
    self.restablecerDaño()
  }

  method disparaJugador() = monitor.turnoDe() == jugador

  method disparaMaquina() = monitor.turnoDe() == ia

  method image() = if(daño == 1) "laEscopetaRecta.png" else "laRecortadaRecta.png"
  // method position() = game.at(14, 6)
  method position() = game.origin()
  method info() = cargador.toString()
} // (1..5).forEach { i =>

object slotEscopeta {
  var seleccionada = false
  method seleccionada() = seleccionada
  method seleccionar() {
    seleccionada = true
    game.addVisual(self)
  }
  method deseleccionar() {
    seleccionada = false
    game.removeVisual(self)
  }

  method position() = escopeta.position()
  method image() = self.imagen()

  method imagen() = if(escopeta.daño() == 1) "laEscopetaSeleccionadaFLECHAS2.png" else "laRecortadaSeleccionadaFLECHAS2.png"
}

object cargadorDeMuestreo {
  var orden = 1
  const valores   = []
  const property cartuchos = []

  method cinturon(unCargador) {
    orden = 1
    valores.clear()
    valores.addAll(unCargador)
    cartuchos.clear()
    valores.forEach{x=>
      self.añadirCartucho(x, orden)
      orden += 1
    }
    cartuchos.forEach{x=>game.addVisual(x)}
    game.schedule(4000, {
      cartuchos.forEach{x=>game.removeVisual(x)}
      cartuchos.clear()
      sonido.balas_recarga()
    })
  }
  method cantValores() = valores.size()
  method añadirCartucho(unValor, unOrden) {
    cartuchos.add(new Cartucho(dispara = unValor, orden = unOrden))
  }
}

class Cartucho {
  const dispara
  const orden

  method autoEliminacion() {
    if(!cargadorDeMuestreo.cartuchos().contains(self) and game.hasVisual(self)) {
      game.removeVisual(self)
    }
  }

  method image() = if(dispara) "balaRojaNitida.png" else "balaAzulNitida.png" ///////////////

  method position() = game.at(20 + orden, 8)

  method initialize() {
    rastreadorObjetos.rastrearCartuchoMuestreo(self)
  }
}

class CartuchoSueltoActivo {
  var posicion = game.origin()
  const dispara

  const nro

  method cartuchosFogueo() = [
    "cartuchoSueltoActivoDeFogueo1.png",
    "cartuchoSueltoActivoDeFogueo2.png"
  ]
  method cartuchosVerdad() = [
    "cartuchoSueltoActivoDeVerdad1.png",
    "cartuchoSueltoActivoDeVerdad2.png"
  ]

  method unoDeVerdad() = self.cartuchosVerdad().get(nro)
  method unoDeFogueo() = self.cartuchosFogueo().get(nro)


  method autoEliminacion() {
    if(!cartuchosEnMesa.cartuchosSueltos().contains(self) and game.hasVisual(self)) {
      game.removeVisual(self)
    }
  }


  method image() = if(dispara) self.unoDeVerdad() else self.unoDeFogueo()
  method position() = posicion
  method initialize() {
    rastreadorObjetos.rastrearCartucho(self)
    cartuchosEnMesa.elegirUnaPosicion()
    posicion = game.at(cartuchosEnMesa.lugarEnMesa().get(0), cartuchosEnMesa.lugarEnMesa().get(1))
    cartuchosEnMesa.nuevoCartuchoSuelto(self)
    game.schedule(3000, {game.addVisual(self)})
  }
}

class CartuchoSueltoUsado inherits CartuchoSueltoActivo {
  override method cartuchosFogueo() = [
    "cartuchoSueltoUsadoDeFogueo1.png",
    "cartuchoSueltoUsadoDeFogueo2.png"
  ]
  override method cartuchosVerdad() = [
    "cartuchoSueltoUsadoDeVerdad1.png",
    "cartuchoSueltoUsadoDeVerdad2.png"
  ]
}

object cartuchosEnMesa {
  var lugarElegido = 0

  const lugaresOcupados = #{}

  const property cartuchosSueltos = []

  method nuevoCartuchoSuelto(unCartuchoSuelto) {cartuchosSueltos.add(unCartuchoSuelto)}

  method lugarElegido() = lugarElegido
  method todosLosLugares() = [
    [16,3], [15,14], [17,10], [19,7], [17,4], [13,9], [14,5], [17,12]
  ]
  
  method lugaresTotales() = #{0, 1, 2, 3, 4, 5, 6, 7}
  
  method lugaresDisponibles() = self.lugaresTotales().difference(lugaresOcupados)

  method unLugarLibre() = self.lugaresDisponibles().anyOne()

  method elegirUnaPosicion() {
    lugarElegido = self.unLugarLibre()
    lugaresOcupados.add(lugarElegido)
  }
  
  method lugarEnMesa() = self.todosLosLugares().get(lugarElegido)

  method barrerCartuchos() {
    cartuchosSueltos.forEach{x=>game.removeVisual(x)}
    cartuchosSueltos.clear()
    lugaresOcupados.clear()
  }
}

object recamara {
  method image() = if (escopeta.recamara()) "laRojaEnRecamara.png" else "laAzulEnRecamara.png"

  method position() = escopeta.position()
}



class AnimacionEscopeta {
  var estoyEnEjecucion = false

  var tiempoElegido = 1000

  var nroFotogramaActual = 0

  method estoyEnEjecucion() = estoyEnEjecucion

  method siguienteFotograma() {nroFotogramaActual = (nroFotogramaActual + 1).min(5)}

  method fotogramaActual() = self.fotogramas().get(nroFotogramaActual)

  method fotogramas()
  
  method itsTimeForTheDurabilityTest() {
    game.removeVisual(escopeta)
    game.addVisual(self)


    estoyEnEjecucion = true
    self.fotogramas().forEach{x=>
      game.schedule(tiempoElegido, {self.siguienteFotograma()})
      tiempoElegido += 1000
    }


    game.schedule(tiempoElegido + 1000, {game.removeVisual(self)})
    game.schedule(tiempoElegido + 1000, {game.addVisual(escopeta)})


    game.schedule(tiempoElegido + 1000, {estoyEnEjecucion = false})

    game.schedule(((self.fotogramas().size() + 1) * 1000), {
      nroFotogramaActual = 0
      tiempoElegido = 1000
    })
  }

  method image() = self.fotogramaActual()

  method position() = escopeta.position()
}

object apuntaArribaBoom inherits AnimacionEscopeta {
  override method fotogramas() = [
    "laEscopetaRecta.png",
    "laEscopetaArriba.png",
    "laEscopetaArribaBOOM.png",
    "laEscopetaArriba.png",
    "laEscopetaRecta.png",
    "laEscopetaRecta.png"
  ]
}

object apuntaArribaNoBoom inherits AnimacionEscopeta {
  override method fotogramas() = [
    "laEscopetaRecta.png",
    "laEscopetaArriba.png",
    "laEscopetaArriba.png",
    "laEscopetaArriba.png",
    "laEscopetaRecta.png",
    "laEscopetaRecta.png"
  ]
}

object apuntaAbajoBoom inherits AnimacionEscopeta {
  override method fotogramas() = [
    "laEscopetaRecta.png",
    "laEscopetaAbajo.png",
    "laEscopetaAbajo.png",  // no ves el disparo porque estas KO, no?
    "laEscopetaAbajo.png",
    "laEscopetaRecta.png",
    "laEscopetaRecta.png"
  ]
}

object apuntaAbajoNoBoom inherits AnimacionEscopeta {
  override method fotogramas() = [
    "laEscopetaRecta.png",
    "laEscopetaAbajo.png",
    "laEscopetaAbajo.png",
    "laEscopetaAbajo.png",
    "laEscopetaRecta.png",
    "laEscopetaRecta.png"
  ]
}




object apuntaArribaBoomRecortada inherits AnimacionEscopeta {
  override method fotogramas() = [
    "laRecortadaRecta.png",
    "laRecortadaArriba.png",
    "laRecortadaArribaBOOM.png",
    "laRecortadaArriba.png",
    "laRecortadaRecta.png",
    "laRecortadaRecta.png"
  ]
}

object apuntaArribaNoBoomRecortada inherits AnimacionEscopeta {
  override method fotogramas() = [
    "laRecortadaRecta.png",
    "laRecortadaArriba.png",
    "laRecortadaArriba.png",
    "laRecortadaArriba.png",
    "laRecortadaRecta.png",
    "laRecortadaRecta.png"
  ]
}

object apuntaAbajoBoomRecortada inherits AnimacionEscopeta {
  override method fotogramas() = [
    "laRecortadaRecta.png",
    "laRecortadaAbajo.png",
    "laRecortadaAbajo.png",  // no ves el disparo porque estas KO, no?
    "laRecortadaAbajo.png",
    "laRecortadaRecta.png",
    "laRecortadaRecta.png"
  ]
}

object apuntaAbajoNoBoomRecortada inherits AnimacionEscopeta {
  override method fotogramas() = [
    "laRecortadaRecta.png",
    "laRecortadaAbajo.png",
    "laRecortadaAbajo.png",
    "laRecortadaAbajo.png",
    "laRecortadaRecta.png",
    "laRecortadaRecta.png"
  ]
}