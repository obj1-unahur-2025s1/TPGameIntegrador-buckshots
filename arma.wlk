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

  method image() = if(daño == 1) "escopeta250.png" else "escopetaRecortada250.png"
  method position() = game.at(14, 6)
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

  method position() = game.at(15, 6)
  method image() = "marcador_escopeta6.png"
}

object cargadorDeMuestreo {
  var orden = 1
  const valores   = []
  const cartuchos = []

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

  method image() = if(dispara) "balaVerdad.png" else "balaFogueo.png"

  method position() = game.at(18 + orden, 9)
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

  method image() = if(dispara) self.unoDeVerdad() else self.unoDeFogueo()
  method position() = posicion
  method initialize() {
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

  const cartuchosSueltos = []

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
  method image() = if (escopeta.recamara()) "recamaraDeVerdad.png" else "recamaraDeFogueo.png"

  method position() = escopeta.position()
}