class Planta {
	var property altura
	var property anyoDeObtencion
	
	method toleranciaAlSol() = 0  //Modificable por hijos
	
	method esFuerte() = self.toleranciaAlSol() > 10  //Queda igual
	
	method daNuevasSemillas() = self.esFuerte() || self.seCumpleCondicionSemillas() //Queda igual
	
	method seCumpleCondicionSemillas() = false  //Modificable por hijos
	
}

class Menta inherits Planta{
	override method toleranciaAlSol() = 6
	
	override method seCumpleCondicionSemillas() =  altura > 0.4
	
	method espacio() = altura * 3
	
	method esParcelaIdeal(parcela) = parcela.superficie() > 6 
}

class Soja inherits Planta{
	override method toleranciaAlSol(){
		if (altura < 0.5){
			return 6
		} else if (altura <= 1){
			return 7
		} else {
			return 9
		}
	}
	
	override method seCumpleCondicionSemillas() = anyoDeObtencion > 2007 && altura > 1
	
	method espacio() = altura / 2
	
	method esParcelaIdeal(parcela) = parcela.horasDeSolPorDia() == self.toleranciaAlSol()
}

class Quinoa inherits Planta{
	var property toleranciaAlSol
	
	override method toleranciaAlSol() = toleranciaAlSol
	 
	override method seCumpleCondicionSemillas() = anyoDeObtencion < 2005	
	
	method espacio() = 0.5
	
	method esParcelaIdeal(parcela) = ! parcela.plantas().any({planta => planta.altura() > 1.5})
}



class SojaTransgenica inherits Soja{
	override method daNuevasSemillas() = false
	
	override method esParcelaIdeal(parcela) = parcela.cantidadMaximaPlantas() == 1
}

class HierbaBuena inherits Menta {
	override method espacio() = altura * 6
}




class Parcela {
	var property ancho
	var property largo
	var property horasDeSolPorDia
	var property plantas
	
	
	method superficie() = ancho * largo
	
	method cantidadMaximaPlantas(){
		if (ancho > largo){
			return (self.superficie() / 5).truncate(0)
		} else {
			return ( self.superficie() / 3 ).truncate(0) + largo
		}
	}
	
	method tieneComplicaciones() = plantas.any({ planta => planta.toleranciaAlSol() < horasDeSolPorDia })
	
	method cantidadDePlantas() = plantas.size()
	
	method plantar(planta){
		if (self.cantidadMaximaPlantas() <= self.cantidadDePlantas() ){
			throw new UserException ("No caben mas plantas")
		}
		if (horasDeSolPorDia >= planta.toleranciaAlSol() + 2){
			throw new UserException ("La planta no tolera la cantidad de sol de la parcela")
		}
		
		plantas.add(planta)
	}
}




class ParcelaEcologica inherits Parcela{ 
	method seAsociaBien(planta) = (! self.tieneComplicaciones()) && planta.esParcelaIdeal(self)
}

class ParcelaIndustrual inherits Parcela{ 
	//Verifica que el maximo POSIBLE de plantas sean 2
	method seAsociaBien(planta) = self.cantidadMaximaPlantas() <= 2 && planta.esFuerte()
}

object q inherits Quinoa (altura = 1, anyoDeObtencion = 2010, toleranciaAlSol = 10){ }

object p inherits ParcelaEcologica (ancho = 1, largo = 10, horasDeSolPorDia = 3, plantas = [q]){}

object inta {
	var property parcelas = [p]
	
	method cantidadDeParcelas() = parcelas.size()
	
	method promedioDePlantas() = parcelas.sum({parcela => parcela.cantidadDePlantas() })
								 / self.cantidadDeParcelas()
								 
	method parcelaMasAutosustentable(){
		self.lasQueTienenMuchasPlantas(parcelas).max({
											parcela => self.porcentajeBienAsociadas(parcela) })
	}
	
	method lasQueTienenMuchasPlantas(parcelas_) =
								parcelas.filter({parcela => parcela.cantidadDePlantas() > 4})

	method porcentajeBienAsociadas(parcela) =	
					parcela.cantidadDePlantas() * self.cantPlantasBienAsociadas(parcela) / 100
	
	method cantPlantasBienAsociadas(parcela) =
						parcela.plantas().filter({ planta => parcela.seAsociaBien(planta) })

}

class UserException inherits Exception { }