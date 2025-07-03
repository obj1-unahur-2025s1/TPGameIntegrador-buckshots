import maquina.*
import logica.*
import mesaCompleta.*
import juego.*
import player.*

object consumision {
    method ejecutar() {
        self.robar()
        self.esposar()
        self.curarse()
        self.tomar()
        self.informarse()
    }

    method curarse() {
        if(ia.vidas() < 4) {
            (1..2).forEach{x=>
                self.curarseSiEsNecesario()
            }
        }
    }
    method curarseSiEsNecesario() {
        if(!ia.fullVida()) {
            ia.usar("Curacion")
        }
    }

    method informarse() {
        (1..(ia.cantConsumibles("Informacion"))).forEach{x=>
            if(!ia.estaLaSe()){
                ia.usar("Informacion")
            }
        }
    }

    method tomar() {
        (1..ia.cantConsumibles("Bebida")).forEach{x=>
            if(ia.pocaDiferencia()) {ia.usar("Bebida")}
        }
    }

    method esposar() {
        if(!jugador.estaEsposado() and ia.hay("Esposas")) {
            ia.usar("Esposas")
        }
    }

    method robar() {
        if(0 < jugador.cantConsumiblesTotal() and ia.hay("Adrenalina")) {
            ia.usar("Adrenalina")
        }
    }
 }