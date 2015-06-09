# Slambda

Pronounced "slam-da", stands for Short Lambda. A tiny library that enables lambda expressions for [Haxe](http://haxe.org) in a simple way.

Can be used with the common `=>` syntax, but also in a shorter format where `_` is assumed to be the first parameter. If more than one argument, use `_1` and `_2`, etc.

## Examples
	
```haxe
// This line is all you need to enable the library:
using Slambda;

class Main {
	static function main() {
		var a : Dynamic;
		
		// Short version, parameter name is set to "_"
		a = [1, 2, 3].filter.fn(_ > 1);
		trace(a); // [2, 3]

		// Normal version, arrow syntax:
		a = [1, 2, 3].filter.fn(x => x > 1);
		trace(a); // [2, 3]

		// For multiple arguments, use _1, _2, etc.
		a = [1, 1, 1].mapi.fn(_1 + _2);
		trace(a); // [1,2,3]

		// Multiple arguments can also be used with arrow syntax, 
		// but must then use brackets:
		a = [1, 1, 1].mapi.fn([i, a] => i + a);
		trace(a); // [1,2,3]

		// When used as a static extension, add rest arguments
		// for functions like fold:
		a = [1, 1, 1].fold.fn(_1 + _2, 10);
		trace(a); // 13

		// Chainable
		a = [1, 2, 3].filter.fn(_ > 1).filter.fn(y => y > 2);
		trace(a); // [3]
	}
}
```

If you import `Slambda.fn`, you can use it without the static extension:

```haxe
import Slambda.fn;

// Only Lambda this time for the sake of the example.
using Lambda;

class Main {
	static function main() {
		var a = [1, 2, 3].filter(fn(_ > 1));
	}
}
```

## Installation

`haxelib install slambda`, then use it in a `hxml` file with `-lib slambda`.
