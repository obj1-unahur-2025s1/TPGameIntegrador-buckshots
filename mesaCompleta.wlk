import arma.*
import consumibles.*
import player.*
import joystick.*
import juego.*
import maquina.*


object mesa {
  var umbralVida = 4
  var dandoObjetos = false
  var nroCartuchoTotales = 0 //
  var nroCartuchoActual = 0 //
  const property jugadores = #{jugador, ia}
  const property elementosNuevaRonda = [jugador, ia, self] //
  
  method umbralVida() = umbralVida

  method nroCartuchoActual() = nroCartuchoActual
  method nroCartuchoTotales() = nroCartuchoTotales
  method siguienteNro() {nroCartuchoActual += 1}
  method anteriorNro() {nroCartuchoActual -= 1} //

  method randomReadyObject() {
    const numerito = self.numerito()
    return
    if(numerito == 1)      {new Cerveza()}
    else if(numerito == 2) {new Serrucho()}
    else if(numerito == 3) {new Esposas()}
    else if(numerito == 4) {new Pucho()}
    else if(numerito == 5) {new Lupa()}
    else if(numerito == 6) {new Venda()}
    else if(numerito == 7) {new Habano()}
    else if(numerito == 8) {new Soda()}
    else if(numerito == 9) {new Telefono()}
    else if(numerito == 10) {new SerruchoOxidado()}
    else if(numerito == 11) {new Pastilla()}
    else if(numerito == 12) {new CervezaVencida()}
    else if(numerito == 13) {new Inversor()}
    else if(numerito == 14) {new Adrenalina()}
    else {new CervezaLight()}
  }
  method numerito() = if(juego.eligioDificil()) (1..15).anyOne() else (1..8).anyOne()
  
  method probabilidad(porcentaje) = 0.randomUpTo(1) < porcentaje
  // El porcentaje sirve de umbral

  method nuevaRonda() {
    maletin.habilitar()
    escopeta.nuevoCargador(self.chequeo(self.nuevoContenidoCargador(self.nuevoLargoDeCartucho())))
    nroCartuchoActual = 1
    nroCartuchoTotales = escopeta.cantCartuchos()
    jugador.nuevaRonda()
    ia.nuevaRonda()

    cargadorDeMuestreo.cinturon(self.ordenDiferente(escopeta.cargador()))

    cartuchosEnMesa.barrerCartuchos()

    game.schedule(1000, {
      game.addVisual(maletin) // Por qué NO me deja en el maletín (???????
      maletin.ponerEnUso()
      maletinIA.ponerEnUso()
    })
  }

  var pausaDeNuevoNivel = false

  method pausaDeNuevoNivel() = pausaDeNuevoNivel
  method estoyEjecutando() {pausaDeNuevoNivel = true}
  method pararEjecucion() {pausaDeNuevoNivel = false}
 
  method primerNivel() {
    self.estoyEjecutando()
    self.nuevoUmbralVida()
    monitor.subirNivel(1)
    game.schedule(7000, {jugadores.forEach{x=>x.primerNivel()}})
    game.schedule(8000, {self.nuevaRonda()})
    game.schedule(9000, {self.pararEjecucion()})
  }

  method subirNivel(unNivel) {
    self.estoyEjecutando()
    self.nuevoUmbralVida()
    monitor.subirNivel(unNivel)
    game.schedule(2000, {self.limpiarObjetos()})
    game.schedule(6000, {jugadores.forEach{x=>x.subirNivel()}})
    game.schedule(8000, {self.nuevaRonda()})
    game.schedule(9000, {self.pararEjecucion()})
  }
  method limpiarObjetos() {jugadores.forEach{x=>x.limpiarObjetos()}}

  method nuevoUmbralVida() {umbralVida = (2..4).anyOne()}

  method nuevoContenidoCargador(unMax) = (1 .. unMax).map{x=>self.probabilidad(0.5)}

  method nuevoLargoDeCartucho() = 2.randomUpTo(8)

  method chequeo(listaDeCartuchos) {
    return
    if(self.todasIguales(listaDeCartuchos)) {
      self.ordenDiferente(self.nuevaDisposicion(listaDeCartuchos))
    } else {
      listaDeCartuchos
    }
  }

  method todasIguales(listaDeCartuchos) = listaDeCartuchos.all{x => x == listaDeCartuchos.head()}

  method nuevaDisposicion(listaDeCartuchos) {
    const mitadFogueo = (1..listaDeCartuchos.size().div(2)).map{x=>false}
    const mitadVerdad = (1..listaDeCartuchos.size() - mitadFogueo.size()).map{x=>true}
    const nuevaDisposicion = mitadFogueo + mitadVerdad
    return nuevaDisposicion
  }

  method ordenDiferente(listaDeCartuchos) {
    const listaElegidos = #{}
    const ordenDiferente = []
    const listaPosiciones = (0 .. listaDeCartuchos.size() - 1).map{x=>x}.asSet()
    const listaPorElegir = listaPosiciones.difference(listaElegidos)
    var posicionElegida = 0
    listaDeCartuchos.forEach{x=>
      posicionElegida = listaPorElegir.anyOne()
      listaElegidos.add(posicionElegida)
      ordenDiferente.add(listaDeCartuchos.get(posicionElegida))
      listaPorElegir.clear()
      listaPorElegir.addAll(listaPosiciones.difference(listaElegidos))
    }
    return ordenDiferente
  }

  method finDelJuego() {if(self.alguienMurio()) {pantalla.final()}}
  method alguienMurio() = false // jugador.muerto() or ia.muerto()

  method image() = "ultimaMesa2.png"

  method position() = game.at(7, 2)
}

class SlotInventario {
  var estaSeleccionado = false
  var property consumible

  const inventarioIa

  const posiciones = [9, 12, 21, 24, 9, 12, 21, 24]

  const numeroAsignado
  
  const excepciones = []

  method usar() {
    if(self.yaEstaEsposado() and consumible.tipoConsumible() == "Esposas") {
      game.say(consumible, "Ya está esposado")
    } else if(self.yaEstaRecortada() and consumible.tipoConsumible() == "Serrucho") {
      game.say(consumible, "Ya está recortada")
    } else {
      self.usarObjeto()
    }
  }
  method usarObjeto() {
    consumible.usar()
    if(consumible.toString() == "a Telefono"){
      game.schedule(4000, {self.limpiar()})
    } else {self.limpiar()}
  }

  method yaEstaEsposado() = monitor.sinTurno().estaEsposado()

  method yaEstaRecortada() = escopeta.daño() == 2

  
  method limpiar() {
    game.removeVisual(consumible)
    consumible = new SlotVacio()
  }
  
  method colocar(unConsumible) {
    consumible = unConsumible
  }

  method image() = "slotActual.png"

  method position() = game.at(posiciones.get(numeroAsignado),if(numeroAsignado < 4) self.filaSuperior() else self.filaInferior())


  method filaSuperior() = if(inventarioIa) 13 else 6
  method filaInferior() = if(inventarioIa) 10  else 3

  method estoySeleccionado() = jugador.slotSeleccionado() == numeroAsignado
}

object numerosEnMesa {
  method position() = mesa.position()
  method image() = "numeros_mesa.png"
}

class SlotVacio {
  method texto() = "vacio.png"

  method usar() {}

  method tipoConsumible() = "SlotVacio"

  method descripcion() = "Sirve para mantener el polimorfismo"

  method mostrarDetalles() {
    if(game.hasVisual(recordatorioAdrenalina)) {
      game.removeVisual(recordatorioAdrenalina)
    }
  }
}

object efectosEstado {
  method image() = if(self.alguienFueEsposado()) "esposaIcono.png" else "vacio.png"
  method position() = if(self.iaFueEsposada()) game.at(10, 17) else game.at(10, 0)

  method alguienFueEsposado() = self.iaFueEsposada() or self.jugadorFueEsposado()
  method iaFueEsposada() = ia.estaEsposado() or ia.perdiUnTurno()
  method jugadorFueEsposado() = jugador.estaEsposado() or jugador.perdiUnTurno()
}

object monitor {
  var imagen = "indicador_nivel_apagado.png"
  var turnoDe = jugador
  const property jugadores = mesa.jugadores()
  
  method turnoDe() = turnoDe
  
  method puedeCambiarTurno() = not self.turnoDe().estaEsposado()

  method cambiarTurno() {
    if(self.sinTurno().estaEsposado()) {
      game.schedule(5000, {
        sonido.sigoEsposado()
        self.sinTurno().desesposar()
        self.sinTurno().perderUnTurno()
      })
    } else {
      turnoDe = self.sinTurno()
    }
  }
  
  method sinTurno() = jugadores.difference(#{turnoDe}).asList().get(0)


  method subirNivel(unNivel) {
    sonido.subirNivel()
    if(unNivel == 1) {
      self.parpadeoNivel("indicador1.png")
    } else if(unNivel == 2) {
      self.parpadeoNivel("indicador2.png")
    } else {
      self.parpadeoNivel("indicador3.png")
    }
  }
  method parpadeoNivel(unNivel) {
    game.removeVisual(mostrarTurno)
    game.schedule(1000, {imagen = unNivel})
    game.schedule(2000, {imagen = "indicador_nivel_apagado.png"})
    game.schedule(3000, {imagen = unNivel})
    game.schedule(4000, {imagen = "indicador_nivel_apagado.png"})
    game.schedule(7000, {game.addVisual(mostrarTurno)})
  }


  method image() = imagen
  method position() = game.at(7, 7)
}

object mostrarTurno {
  method image() = if(monitor.turnoDe() == ia) "monitor_turno_maquina.png" else "monitor_turno_player.png"
  method position() = monitor.position()
}


object maletin {
  var estoyEnUso = false
  
  const property objetosEnInventario = []

  method estoyEnUso() = estoyEnUso
  method habilitar() {estoyEnUso = true}
  method desabilitar() {estoyEnUso = false}

  method nuevoObjetoInventario(unConsumible) {objetosEnInventario.add(unConsumible)}
  
  method ponerEnUso() {
    
    game.schedule(1000, {self.desafortunado()})
  }

  method desafortunado() {
    if(self.sinObjetos()) {
      game.say(self, "Qué desafortunado")
      // self.desabilitar()
      game.schedule(2000, {self.sacarMaletin()})
    } else {
      recordatorioTeclas.mostrarSeguro()
      juego.empezarGameplay()
      objetoEspejo.imagen(objetosEnInventario.get(0).image())
      juego.despausar()
      // game.addVisual(objetosEnInventario.first())
      // objetosEnInventario.remove(objetosEnInventario.get(0))
    }
  }

  method siguienteObjetoSiHay() {
    if(self.sinObjetos()) {
      self.sacarMaletin()
    } else {
      game.addVisual(objetosEnInventario.get(0))
      objetosEnInventario.remove(objetosEnInventario.get(0))
      self.siguienteObjeto()
    }
  }

  method siguienteObjeto() {
    if(self.sinObjetos()) {
      self.sacarMaletin()
    } else {
      objetoEspejo.imagen(objetosEnInventario.get(0).image())
    }
  }
  
  method sacarMaletin() {
    objetoEspejo.imagen("vacio.png")
    game.schedule(1000, {
      game.removeVisual(self)
      self.desabilitar()
    })
    // objetosEnInventario.clear()
  }

  method sinObjetos() = objetosEnInventario.isEmpty()

  // method image() = if(self.sinObjetos()) "maleton.png" else "maletonConControles"

  method image() = "maleton.png"

  method position() = game.at(15, 3)
}

object maletinIA {
  var tiempoElegido = 1000

  const objetosInventarioIA = []

  method nuevoObjeto(unConsumible) = objetosInventarioIA.add(unConsumible)

  method ponerEnUso() {
    game.addVisual(self)
    objetosInventarioIA.forEach{x=>
      game.schedule(tiempoElegido, {game.addVisual(x)})
      tiempoElegido += 1000
    }
    objetosInventarioIA.clear()
    game.schedule((tiempoElegido) + 1000, {game.removeVisual(self)})
    tiempoElegido = 1000
  }

  method position() = game.at(15, 11)

  method image() = "maletin_ia_205.png"
}


class Descripcion {
  var imagen = "vacio.png"

  method imagen(nuevaImagen) {
    game.removeVisual(self)
    imagen = nuevaImagen
    game.addVisual(self)
  }

  method position()

  method image() = imagen
}


object objetoEspejo inherits Descripcion{
  override method position() = game.at(16, 4)
}



object textoConsumible inherits Descripcion{
  override method position() = game.at(14, 4)
}

object rastreadorObjetos {
  const property objetosRastreados = []
  const property cartuchosRastreados = []
  const property cartuchosMuestreoRastreados = []

  method rastrearCartuchoMuestreo(uncartucho) {cartuchosMuestreoRastreados.add(uncartucho)}
  method rastrearCartucho(uncartucho) {cartuchosRastreados.add(uncartucho)}
  method rastrearConsumible(unConsumible) {objetosRastreados.add(unConsumible)}
}