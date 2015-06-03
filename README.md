# Slambda

Pronounced "slam-da", stands for Short Lambda. I was tired of those long lambdas so here's a shorter version (including those long ones as well, if needed!)

```haxe
// Use both Lambda and Slambda for best effect.
using Lambda;
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

		// Use fn1...fn4 for 1-4 rest arguments
		a = [1, 1, 1].fold.fn1([i, a] => i + a, 10);
		trace(a); // 13

		// Chainable
		a = [1, 2, 3].filter.fn(x > 1).filter.fn(y => y > 2);
		trace(a); // [3]
	}
}
```
