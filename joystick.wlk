import player.*
import juego.*
import arma.*
import mesaCompleta.*

object joystick {
  method slotSiguiente() {
    if (self.bordeDerecho()) jugador.slotSeleccionado(
        self.inicioDeFila(jugador.slotSeleccionado())
      )
    else jugador.slotSeleccionado(jugador.slotSeleccionado() + 1)
  }
  
  method bordeDerecho() = (jugador.slotSeleccionado() == 3) or (jugador.slotSeleccionado() == 7)
  
  method inicioDeFila(unaPosicion) {
    if (unaPosicion == 3) {
      return 0
    } else {
      return 4
    }
  }
  
  method slotAnterior() {
    if (self.bordeIzquierdo()) jugador.slotSeleccionado(
        self.finalDeFila(jugador.slotSeleccionado())
      )
    else jugador.slotSeleccionado(jugador.slotSeleccionado() - 1)
  }
  
  method bordeIzquierdo() = (jugador.slotSeleccionado() == 0) or (jugador.slotSeleccionado() == 4)
  
  method finalDeFila(unaPosicion) {
    if (unaPosicion == 0) {
      return 3
    } else {
      return 7
    }
  }
  
  method slotSuperior() {
    if (self.bordeSuperior()) jugador.slotSeleccionado(
        jugador.slotSeleccionado() + 4
      )
    else jugador.slotSeleccionado(jugador.slotSeleccionado() - 4)
  }
  
  method bordeSuperior() = jugador.slotSeleccionado() < 4
  
  method slotInferior() {
    if (self.bordeInferior()) jugador.slotSeleccionado(
        jugador.slotSeleccionado() - 4
      )
    else jugador.slotSeleccionado(jugador.slotSeleccionado() + 4)
  }
  
  method bordeInferior() = jugador.slotSeleccionado() >= 4

  method seleccionarEscopeta() {slotEscopeta.seleccionar()}
  method deseleccionarEscopeta() {slotEscopeta.deseleccionar()}
}


object manejoJoystick {

  method usarEscopeta() {
    if(self.miTurno() and !slotEscopeta.seleccionada()) {
      sonido.seleccionEscopeta()
      joystick.seleccionarEscopeta()
      self.quitarEscopetaSegura() //
    } else if(self.miTurno()) {
      self.quitarEscopetaSegura() //
      joystick.deseleccionarEscopeta()
    }
  }
  method dejarEscopeta() {
    if(self.miTurno()) {
      joystick.deseleccionarEscopeta()
      game.removeVisual(slotEscopeta)
    }
  }

  method quitarEscopetaSegura() {
    if(game.hasVisual(escopeta)) {
      game.removeVisual(escopeta)
    } else {
      game.addVisual(escopeta)
    }
  }


  method mostrarSlot(unaPosicion) {
    jugador.inventario().forEach{x=>game.removeVisual(x)}
    game.addVisual(jugador.inventario().get(unaPosicion))
  }

  method derecha() {
    if(self.miTurno() and not maletin.estoyEnUso()) {
      sonido.seleccion()
      joystick.slotSiguiente()
      self.mostrarSlot(jugador.slotSeleccionado())

      self.mostrarDescripcion()
    }
  }
  method izquierda() {
    if(self.miTurno() and not maletin.estoyEnUso()) {
      sonido.seleccion()
      joystick.slotAnterior()
      self.mostrarSlot(jugador.slotSeleccionado())

      self.mostrarDescripcion()
    }
  }
  method arriba() {
    if(self.miTurno() and not maletin.estoyEnUso()) {
      sonido.seleccion()
      joystick.slotSuperior()
      self.mostrarSlot(jugador.slotSeleccionado())

      self.mostrarDescripcion()
    }
  }
  method abajo() {
    if(self.miTurno() and not maletin.estoyEnUso()) {
      sonido.seleccion()
      joystick.slotInferior()
      self.mostrarSlot(jugador.slotSeleccionado())
      
      self.mostrarDescripcion()
    }
  }

  method mostrarDescripcion() {
    textoConsumible.imagen(jugador.inventario().get(jugador.slotSeleccionado()).consumible().texto())
    jugador.inventario().get(jugador.slotSeleccionado()).consumible().mostrarDetalles()
  }

  method miTurno() = monitor.turnoDe() == jugador
}