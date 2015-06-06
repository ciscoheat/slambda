# Slambda

Pronounced "slam-da", stands for Short Lambda. I was tired of those long lambdas so here's a shorter version (including those long ones as well, if needed!)

```haxe
using Slambda;

class Main {
	static function main() {
		var a : Dynamic;
		
		// Super-short version (parameter name autodetected)
		a = [1, 2, 3].filter.fn(i > 1);
		trace(a); // [2, 3]

		// Normal version, with or without brackets
		a = [1, 2, 3].filter.fn(x => x > 1);
		trace(a); // [2, 3]

		// Multiple arguments must use brackets
		a = [1, 1, 1].mapi.fn([i, a] => i + a);
		trace(a); // [1,2,3]

		// Add 1-4 rest arguments for functions like fold
		a = [1, 1, 1].fold.fn([i, a] => i + a, 10);
		trace(a); // 13

		// Chainable
		a = [1, 2, 3].filter.fn(x > 1).filter.fn(y => y > 2);
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
		var a = [1, 2, 3].filter(fn(i > i));
	}
}
```

## Parameter autodetection?

Yes, it looks for the first identifier in the construct and uses that one. It enables a natural syntax like

```haxe
var emails = persons.filter.fn(person.email != null).map.fn(person.email);
```

If you're doing complicated stuff and/or it seems to fail, use the normal `person => ...` syntax instead, or create an issue with the case so I can improve the detection.

## Installation

`haxelib git slambda https://github.com/ciscoheat/slambda.git master src`
