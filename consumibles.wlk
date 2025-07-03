import arma.*
import player.*
import mesaCompleta.*
import maquina.*
import juego.*

// Agregar una moneda, si sale cara sobas objeto, sino te roba objeto a vos
// Agregar revolver de dudosa calidad: Dispara por la culata, dispara bien, dispara cartelito (Se puede disparar a uno o al otro)
class Consumible {
  var position = game.at(16, 4)
  
  method tipoConsumible()
  
  method usar()
  
  method descripcion()
  
  method position() = position
  
  method nuevaPosicion(unaPosicion) {
    position = unaPosicion
  }
  
  method image()
} // Pensar métodos en común a todos los consumibles

///////////////BEBIDAS/////////////////
class Bebida inherits Consumible {
  override method tipoConsumible() = "Bebida"
  
  override method usar() {
    
    sonido.bebida()
    escopeta.vaciarRecamara()
    game.schedule(3000, {escopeta.añadirCartuchoActivoAMesa(escopeta.recamara())}) 
    mesa.siguienteNro()
    escopeta.nuevaRondaSiNecesario()
  
  }
  
  override method descripcion() = "Descarta la siguiente bala en el cartucho"
}

class Cerveza inherits Bebida {
  override method usar() {
    //escopeta.enRecamara() // Hacer que muestre al jugador la bala que salió
    super()
  }
  
  override method descripcion() = super() + ", mostrando qué bala era"
  
  override method image() = "birra.png"
}

class CervezaLight inherits Cerveza {
  override method usar() {
    super()
    // turno.turnoDe().inhabilitar("Curacion") // Hacer que no pueda usar consumibles de tipo "Curacion"
  }
  
  override method image() = "cervezalight.png"
}

class CervezaVencida inherits Cerveza {
  override method usar() {
    super()
    if (mesa.probabilidad(0.25)) {
      monitor.turnoDe().quitarVida(1, 7000)
      game.schedule(4000, {sonido.desfibrilador()})
      self.pantallazo()
    }
  }
  method pantallazo() {
    if(monitor.turnoDe() == jugador){
      game.schedule(3000, {pantallazo.pantallaNegra()})
    }
  }
  
  override method descripcion() = super() + ". Con probabilidad del 25% de perder 1 de vida"
  
  override method image() = "cerveza_vencida.png"
}

class Soda inherits Bebida {
  override method usar() {
    if (1 < escopeta.cantCartuchos()) {
      super()
      escopeta.vaciarRecamara()
      mesa.siguienteNro()
      game.schedule(4000, {escopeta.añadirCartuchoActivoAMesa(escopeta.recamara())})
    } else {
      super()
    }
    escopeta.nuevaRondaSiNecesario()
  }
  
  override method descripcion() = "Descarta y muestra las siguientes 2 balas en el cartucho"
  
  override method image() = "jugo.png"
} ///////////////CURACION/////////////////

class Curacion inherits Consumible {
  override method tipoConsumible() = "Curacion"
  
  override method usar() {
    monitor.turnoDe().sumarVida(1)
  }
  
  override method descripcion() = "Cura 1 de vida"
} // Pasar a abstracta

class Pucho inherits Curacion {
  override method usar() {
    sonido.puchos()
    super()
  }
    
  override method image() = "cigarrillos.png"
}

class Habano inherits Pucho {
  override method usar() {
    sonido.puchos()
    
    if (mesa.probabilidad(0.5)) monitor.turnoDe().sumarVida(2) 
    else super()
  }
  
  override method descripcion() = super() + ", con probabilidad de curar 2 puntos"
  
  override method image() = "abanoChico.png"
}

class Venda inherits Curacion {
  override method usar() {
    sonido.vendas()
    monitor.turnoDe().sumarVida(2) 
  }
  
  override method descripcion() = "Cura 2 de vida"
  
  override method image() = "vendasChicas.png"
}

class Pastilla inherits Curacion {
  override method usar() {
    if (mesa.probabilidad(0.5)) {
      sonido.pildoraGanas()
      monitor.turnoDe().sumarVida(2) 
    } else {
      sonido.pildoraPerdes()
      monitor.turnoDe().quitarVida(1, 9000)
      mesa.finDelJuego()
      game.schedule(5000, {sonido.desfibrilador()})
      game.schedule(5000, {self.pantallazo()})
    }
  }
  method pantallazo() {
    if(monitor.turnoDe() == jugador){
      pantallazo.pantallaNegra()
    }
  }

  override method descripcion() = "Cura 2 de vida... o pierde 1"
  
  override method image() = "pildoras.png"
} ///////////////SERRUCHO/////////////////

class Serrucho inherits Consumible {
  override method tipoConsumible() = "Serrucho"
  
  override method usar() {
    escopeta.duplicarDaño()
    sonido.serrucho()
  }
  
  override method descripcion() = "Duplica el daño del siguiente disparo"
  
  override method image() = "serruchoGod.png"
}

class SerruchoOxidado inherits Serrucho {
  override method usar() {
    if (mesa.probabilidad(0.25)) {
      super()
    } else {
      super()
      escopeta.falsearRecamara()
    }
  }
  
  override method descripcion() = super() + "... con un 25% de inhabilitar el siguiente disparo"
  
  override method image() = "serruchoGodOxidado.png"
}

class Informacion inherits Consumible {
  override method tipoConsumible() = "Informacion"
  
  override method descripcion() = "Brinda información acerca de"
}

class Lupa inherits Informacion {
  override method descripcion() = super() + "l cartucho en la recamara"
  
  override method usar() {
    sonido.lupa()
    if (self.chequearTurno(ia)) self.turnoMaquina() else self.turnoJugador()
  }
  
  method chequearTurno(alguien) = monitor.turnoDe() == alguien
  
  method turnoMaquina() {
    if (escopeta.recamara()) {
      ia.nuevaDeVerdad(mesa.nroCartuchoActual())
    }
    else {
      ia.nuevaDeFogueo(mesa.nroCartuchoActual())
    }
  }
  
  method turnoJugador() {
    game.schedule(3500, {escopeta.mostrarRecamara()})
  }
  
  override method image() = "lupa.png"
}

class Telefono inherits Informacion {
  var imagen = "telefonoApagado.png"
  
  override method descripcion() = super() + " una posición del cargador"
  
  override method usar() {
    sonido.telefono()
    imagen = "telefonoPrendido.png"
    game.schedule(3000, { imagen = "telefonoSinSeñal.png" })
    if (escopeta.cantCartuchos() <= 2) game.say(self, "Que desafortunado")
    else self.darInformacion()
  }
  
  method darInformacion() {
    if (self.miTurno()) game.say(
        self,
        ("Posicion " + self.posicion().toString()) + self.mensaje()
      )
    else self.informarMaquina()
  }
  
  method informarMaquina() {
    if (self.cartucho()) ia.nuevaDeVerdad(self.posicion())
    else ia.nuevaDeFogueo(self.posicion())
  }
  
  method posicion() = (2 .. (escopeta.cantCartuchos() - 1)).anyOne()
  
  method cartucho() = escopeta.cartuchoEnPosicion(self.posicion())
  
  method mensaje() = if (self.cartucho()) ", cartucho de verdad" else ", cartucho de fogueo"
  
  method miTurno() = monitor.turnoDe() == jugador
  
  override method image() = imagen
}


class Inversor inherits Consumible {
  override method tipoConsumible() = "Inversor"
  override method descripcion() = "Invierte el valor de la bala en la recamara"
  
  override method usar() {
    sonido.inversor()
    escopeta.invertirBala()
  }
  
  override method image() = "inverter.png"
}


class Esposas inherits Consumible {
  override method tipoConsumible() = "Esposas"
  override method descripcion() = "Esposa al adversario, haciéndole perder un turno"
  
  override method usar() {
    sonido.ponerEsposas()
    monitor.sinTurno().esposar()
  }
    
  override method image() = "esposa.png"
}
class Adrenalina inherits Consumible {
  override method tipoConsumible() = "Adrenalina"
  override method descripcion() = "Roba un objeto y úsalo al instante, tenes 7 segundos"
  
  override method usar() {
    sonido.inyeccion()
    if(self.turnoActual(ia)) {self.usoIa()}
    else {self.usoJugador()}
  }

  method usoJugador() {
    monitor.turnoDe().podesRobar()
    game.schedule(7000, {if(jugador.puedeRobar()) {jugador.noPodesRobar()}})
  }

  method usoIa() {
    jugador.unConsumible().usar() // Qué pasa si roba un serrucho o unas esposas y no las puede usar?
  }

  method turnoActual(unJugador) = monitor.turnoDe() == unJugador
  override method image() = "inyeccion.png"
}