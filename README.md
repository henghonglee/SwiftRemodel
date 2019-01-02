# SwiftRemodel

Generates boilerplate matchers to encourage use of Immutable Value Objects and Algebraic Data types

# Install

`brew install henghonglee/formulae/swift-remodel`

# Use

`swift-remodel <path-to-directory-containing-swift-files>` 

or 

`swift-remodel <path-to-swift-file>`

# Sample # 
(https://github.com/henghonglee/HelloDesserts)
###  Input: DataModel.swift
```
struct Doughnut {
  enum DoughnutTopping {
    case sprinkles
    case fudge
    case strawberryFudge
    case cinnamonSugar
  }
  var topping: DoughnutTopping?
}

struct Cake {
  enum CakeType {
    case pound
    case sponge
    case angel
    case chiffon
  }
  let type: CakeType
}

struct CookieIceCream {
  let iceCream: IceCream
  let cookie: Cookie
}

struct Cookie {
  enum Filling {
    case chocolateChips
    case marshmallow
  }
  var filling: Filling?
}

struct IceCream {
  enum Flavor {
    case vanilla
    case chocolate
    case strawberry
  }
  let flavor: Flavor
}

struct Dessert {
  enum DessertType {
    case doughnut(Doughnut)
    case cake(Cake)
    case cookie(Cookie)
    case icecream(IceCream)
    case cookieIceCream(CookieIceCream)
    case pastry
    case pudding
    case candy
  }
  let price: Double
  let calories: Double
  let type: DessertType
}
```

### Output: DataModel__Enum+Match.swift

```
/* This file was generated from DataModel.swift */
import Foundation

extension Cake.CakeType {
  func match(pound:()->Void, sponge:()->Void, angel:()->Void, chiffon:()->Void) {
    switch self {
    case .pound:
      pound()
    case .sponge:
      sponge()
    case .angel:
      angel()
    case .chiffon:
      chiffon()
    }
  }
}
extension Cookie.Filling {
  func match(chocolateChips:()->Void, marshmallow:()->Void) {
    switch self {
    case .chocolateChips:
      chocolateChips()
    case .marshmallow:
      marshmallow()
    }
  }
}
extension Dessert.DessertType {
  func match(doughnut:(Doughnut)->Void, cake:(Cake)->Void, cookie:(Cookie)->Void, icecream:(IceCream)->Void, cookieIceCream:(CookieIceCream)->Void, pastry:()->Void, pudding:()->Void, candy:()->Void) {
    switch self {
    case .doughnut(let param0):
      doughnut(param0)
    case .cake(let param0):
      cake(param0)
    case .cookie(let param0):
      cookie(param0)
    case .icecream(let param0):
      icecream(param0)
    case .cookieIceCream(let param0):
      cookieIceCream(param0)
    case .pastry:
      pastry()
    case .pudding:
      pudding()
    case .candy:
      candy()
    }
  }
}
extension Doughnut.DoughnutTopping {
  func match(sprinkles:()->Void, fudge:()->Void, strawberryFudge:()->Void, cinnamonSugar:()->Void) {
    switch self {
    case .sprinkles:
      sprinkles()
    case .fudge:
      fudge()
    case .strawberryFudge:
      strawberryFudge()
    case .cinnamonSugar:
      cinnamonSugar()
    }
  }
}
extension IceCream.Flavor {
  func match(vanilla:()->Void, chocolate:()->Void, strawberry:()->Void) {
    switch self {
    case .vanilla:
      vanilla()
    case .chocolate:
      chocolate()
    case .strawberry:
      strawberry()
    }
  }
}
```
