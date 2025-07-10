import maquina.*
import mesaCompleta.*
import arma.*

class Estrategia {
    const valor

    method valor() {
        return
        if(self.esViable()) {
            valor
        } else 0
    }

    method esViable() = true

    method ejecutar() 

    method usarSerrucho() {
        if(ia.hay("Serrucho")){
            ia.usar("Serrucho")
            game.schedule(4000, {
                self.dispararSiSePuede()
        })
        } else {
            self.dispararSiSePuede()
        }
    }

    method usarInversor() {
        if(ia.hay("Inversor")) {
            ia.usar("Inversor")
            game.schedule(4000, {
                self.dispararSiSePuede()
        })
        } else {
            self.dispararseSiSePuede()
        }
    }

    method dispararSiSePuede() {
        if(not escopeta.sinBalas()) {
            escopeta.dispararAbajo(ia)
            game.schedule(4000, {ia.termineEjecucion()})
        } else {
            ia.termineEjecucion()
        }
    }
    method dispararseSiSePuede() {
        if(not escopeta.sinBalas()) {
            escopeta.dispararArriba(ia)
            game.schedule(4000, {ia.termineEjecucion()})
        } else {
            ia.termineEjecucion()
        }
    }
}

class TiroSeguro inherits Estrategia{
    override method esViable() = ia.estaLaSe()

    override method ejecutar() {
        if(ia.estaPega()) {
            self.usarSerrucho()
        } else {
            self.usarInversor()
        }
    }
}

class Default inherits Estrategia{ // Si hay 2 balas más de mentira que de verdad, se autoDispara
    override method ejecutar() {
        if(ia.cantVerdad() <= (ia.cantFogueo() - 2)) {
            escopeta.dispararArriba(ia)
            game.schedule(4000, {ia.termineEjecucion()})
        } else {
            escopeta.dispararAbajo(ia)
            game.schedule(4000, {ia.termineEjecucion()})
        }
    }
}

class est3 inherits Estrategia{
    
}


