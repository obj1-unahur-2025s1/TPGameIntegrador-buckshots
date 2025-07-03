import mesaCompleta.*
import arma.*
import consumibles.*
import joystick.*
import maquina.*
import juego.*

object jugador {
  var topeVidas = 4

  var property slotSeleccionado = 0
  var property vidas = 0
  var nombre = null
  var estaEsposado = false
  var perdiUnTurno = false
  var puedeRobar = false

  method nuevoTopeVidas(nuevoTope) {topeVidas = nuevoTope}

  method perdiUnTurno() = perdiUnTurno
  method perderUnTurno() {perdiUnTurno = true}
  method liberarse() {perdiUnTurno = false}

  method puedeRobar() = puedeRobar
  method podesRobar() {puedeRobar = true; game.addVisual(numerosEnMesa)}
  method noPodesRobar() {puedeRobar = false; game.removeVisual(numerosEnMesa)}

  method muerto() = vidas == 0

  method esposar() {estaEsposado = true}
  method desesposar() {estaEsposado = false}

  method estaEsposado() = estaEsposado

  const property inventario = []

  method vaciarInventario() {inventario.forEach( {x => x.limpiar()} )}

  method iniciarInventario(listaSlots) {
    inventario.addAll(listaSlots)
  }

  method hay(unConsumible) = inventario.any( {x => x.consumible().codigo() == unConsumible} ) // codigo ya no es, cambia a: "tipoConsumible()"

  method usar(unConsumible) {
    if(self.hay(unConsumible)){
      self.todosLos(unConsumible).first().usar()
    }
  }

  method todosLos(unConsumible) = inventario.filter( {x => x.consumible().codigo() == unConsumible} ) // Requiere una referencia

  method cantConsumibles(unConsumible) = inventario.count( {x => x.consumible().codigo() == unConsumible} ) // Requiere una referencia


  method nuevosConsumibles(unaCant) {
    (1 .. unaCant).forEach{x =>
      if(self.hayEspacio()) {
        self.nuevoConsumible()
      } 
    }
  }

  method nuevoConsumible() {
    var consumibleRandom = mesa.randomReadyObject()
    var slotElegido = self.unSlotVacio()
    slotElegido.colocar(consumibleRandom)
    consumibleRandom.nuevaPosicion(slotElegido.position())
    maletin.nuevoObjeto(self.unoAsi(consumibleRandom))
    maletin.nuevoObjetoInventario(consumibleRandom)
  }
  method unoAsi(unConsumible) {
    return
    if     (unConsumible.toString() == "a Cerveza")         {new Cerveza()}
    else if(unConsumible.toString() == "a CervezaLight")    {new CervezaLight()}
    else if(unConsumible.toString() == "a CervezaVencida")  {new CervezaVencida()}
    else if(unConsumible.toString() == "a Soda")            {new Soda()}
    else if(unConsumible.toString() == "a Pucho")           {new Pucho()}
    else if(unConsumible.toString() == "a Habano")          {new Habano()}
    else if(unConsumible.toString() == "a Venda")           {new Venda()}
    else if(unConsumible.toString() == "a Pastilla")        {new Pastilla()}
    else if(unConsumible.toString() == "a Serrucho")        {new Serrucho()}
    else if(unConsumible.toString() == "a SerruchoOxidado") {new SerruchoOxidado()}
    else if(unConsumible.toString() == "a Lupa")            {new Lupa()}
    else if(unConsumible.toString() == "a Telefono")        {new Telefono()}
    else if(unConsumible.toString() == "a Inversor")        {new Inversor()}
    else if(unConsumible.toString() == "a Esposas")         {new Esposas()}
    else if(unConsumible.toString() == "a Adrenalina")      {new Adrenalina()}
    else {new Adrenalina()}
  }

  method unSlotVacio() = inventario.find( {x => x.consumible().tipoConsumible() == "SlotVacio"} )

  // Inicializo una constante con una instancia de clase x
  // La guardo en un SlotInventario
  // La busco en el inventario
  // Le actualizo la posición



    

  method sumarVida(unValor) {
    vidas = (vidas + unValor).min(topeVidas)
    sonido.ganarVida()
  }

  method quitarVida(unValor, delay) {
    game.schedule(delay, {
      vidas = (vidas - unValor).max(0)
      sonido.perderVida()
      self.perderSiAmerita()
    })
  }
  method perderSiAmerita() {
    if(self.muerto()) {
      pantalla.final()
    }
  }
  
  method nuevaRonda() {
    self.nuevosConsumibles(mesa.nroCartuchoTotales().div(2))
    maletin.ponerEnUso()
  }

  method primerNivel() {
    if(juego.eligioDificil()) {
      self.nuevoTopeVidas(mesa.umbralVida())
    }
    self.sumarVida(4)
  }

  method subirNivel() {
    if(juego.eligioDificil()) {
      self.nuevoTopeVidas(mesa.umbralVida())
    }
    self.sumarVida(4)
  }
  method limpiarObjetos() {inventario.forEach{x=>x.limpiar()}}

  
  method recibirDisparo(unDaño) {
    pantallazo.pantallaNegra()
    self.quitarVida(unDaño, 5000)
  }

  method usarSlotSeleccionado() {inventario.get(slotSeleccionado).usar()}

  method hayEspacio() = 0 < self.espaciosDisponibles() 

  method espaciosDisponibles() = inventario.count{x=>x.consumible().tipoConsumible() == "SlotVacio"}

  method slotActual() = inventario.get(slotSeleccionado)

  method consumibleSeleccionado() = self.slotActual().consumible()

  method descripcionDelSeleccionado() = self.consumibleSeleccionado().descripcion()

  method cantConsumiblesTotal() = inventario.count{x=>not (x.consumible().tipoConsumible() == "SlotVacio")}

  method todosLosConsumibles() = inventario.filter{x=> not (x.consumible().tipoConsumible() == "SlotVacio")}

  method unConsumible() = self.todosLosConsumibles().anyOne()

  method image() {
    return
    if(vidas == 4) "contador4.png"
    else if(vidas == 3) "contador3.png"
    else if(vidas == 2) "contador2.png"
    else if(vidas == 1) "contador1.png"
    else "contador0.png"
  }

  method position() = game.at(27, 3)

  method jugarSiCorresponde() {
    if(self.estaEsposado()) {
      sonido.sigoEsposado()
      game.schedule(1500, {
        monitor.cambiarTurno()
        self.perderUnTurno()
      })
    } else if(perdiUnTurno) {
      sonido.meLibero()
      self.liberarse()
    }
  }
}

