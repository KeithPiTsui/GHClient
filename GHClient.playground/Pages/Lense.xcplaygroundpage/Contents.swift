//: [Previous](@previous)

import Foundation



struct Lens<Whole, Part> {
  var store: (Whole) -> (Part, (Part) -> Whole)
}

extension Lens {
  var get: (Whole) -> Part {
    return { whole in
      self.store(whole).0
    }
  }

  var set: (Whole) -> (Part) -> (Whole) {
    return { whole in
      self.store(whole).1
    }
  }
}

extension Lens {
  func composition<NewPart>(other: Lens<Part, NewPart>) -> Lens<Whole, NewPart> {
    return Lens<Whole, NewPart>(store: { (whole: Whole) -> (NewPart, (NewPart) -> Whole) in
      let getter: NewPart = other.get(self.get(whole))

      let setter: (NewPart) -> Whole = { (newPart: NewPart) -> Whole in
        let part = self.get(whole)
        let newPartOfWhole = other.set(part)(newPart)
        return self.set(whole)(newPartOfWhole)
      }

      return (getter, setter)
    })
  }
}

struct City {
  let name: String
  let country: String
}

extension City {
  enum lense {
    static var name: Lens<City, String> {
      return Lens(store: { (city) -> (String, (String) -> City) in
        return (city.name, { name in City(name: name, country: city.country) })
      })
    }
  }
}


struct Person {
  let name: String
  let city: City
}

extension Person {
  enum lense {
    static var name: Lens<Person, String> {
      return Lens(store: { (person) -> (String, (String) -> Person) in
        return (person.name, { name in Person(name: name, city: person.city) })
      })
    }

    static var city: Lens<Person, City> {
      return Lens(store: { (person) -> (City, (City) -> Person) in
        return (person.city, { city in Person(name: person.name, city: city) })
      })
    }
  }
}

extension Person.lense {
  static var cityname: Lens<Person, String> {
    return Person.lense.city.composition(other: City.lense.name)
  }
}


let myCity = City(name: "Guangzhou", country: "China")
let myPerson = Person(name: "Keith", city: myCity)

let personCityNameLen = Person.lense.cityname
personCityNameLen.get(myPerson)
let newMe = personCityNameLen.set(myPerson)("Shenzhen")

infix operator |>

/// getter function
func |> <Whole, Part> (whole: Whole, lense: Lens<Whole, Part>) -> Part {
  return lense.get(whole)
}

infix operator •
func • <Whole, Part, NewPart> (lhs: Lens<Whole, Part>, rhs: Lens<Part, NewPart>)
  -> Lens<Whole, NewPart> {
    return lhs.composition(other: rhs)
}

myPerson |> Person.lense.cityname

infix operator .~
func .~ <Whole, Part> (len: Lens<Whole, Part>, part: Part) -> (Whole) -> (Whole) {
  return { (whole: Whole) -> Whole in
    return len.set(whole)(part)
  }
}

func |> <Whole> (whole: Whole, process: (Whole) -> Whole) -> (Whole) {
  return process(whole)
}

 let newPerson = myPerson |> (Person.lense.cityname .~ "Shenzhen")






//: [Next](@next)
