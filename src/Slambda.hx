import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ExprTools;

// Auto-import Lambda when using Slambda
typedef SlambdaLambda = Lambda;

class Slambda
{
	public macro static function fn<T, T2>(fn : ExprOf<T -> T2>, exprs : Array<Expr>) {
		return SlambdaMacro.f(fn, exprs, 0);
	}
}

class Slambda1
{
	public macro static function fn<T, T2, T3>(fn : ExprOf<T -> T2 -> T3>, exprs : Array<Expr>) {
		return SlambdaMacro.f(fn, exprs, 1);
	}
}

class Slambda2
{
	public macro static function fn<T, T2, T3, T4>(fn : ExprOf<T -> T2 -> T3 -> T4>, exprs : Array<Expr>) {
		return SlambdaMacro.f(fn, exprs, 2);
	}
}

class Slambda3
{
	public macro static function fn<T, T2, T3, T4, T5>(fn : ExprOf<T -> T2 -> T3 -> T4 -> T5>, exprs : Array<Expr>) {
		return SlambdaMacro.f(fn, exprs, 3);
	}
}

class Slambda4
{
	public macro static function fn<T, T2, T3, T4, T5>(fn : ExprOf<T -> T2 -> T3 -> T4 -> T5>, exprs : Array<Expr>) {
		return SlambdaMacro.f(fn, exprs, 4);
	}	
}

private class SlambdaMacro
{
	public static function f(fn : Expr, exprs : Array<Expr>, expectedRest : Int) {
		// If called through an extension, "exprs" contains the lambda expression.
		var extension = exprs != null && exprs.length > 0;

		// If not an extension, move the lamba expr. to "exprs" for processing.
		if (!extension) exprs = [fn];	
		
		if (exprs.length-1 != expectedRest)
			untyped Context.error('Invalid number of rest arguments, $expectedRest expected.', exprs[exprs.length - 1].pos);

		// If no rest arguments, test if the function was called as an extension, then apply the extension function.
		function addExtension(e : Expr) return extension ? macro $fn($e) : e;

		var restError = "Too many rest arguments, max 4 supported.";
		var e = exprs.shift();
		
		switch e.expr {
			case EBinop(OpArrow, _, _):
			case _: 
				// Detect underscore arguments
				var params = new Map<String, Expr>();
				function findParams(e : Expr) {
					switch e.expr {
						case EConst(CIdent(v)) if (v == "_" || v == "_1" || v == "_2" || v == "_3" || v == "_4"):
							params.set(v, e);
						case _:
							e.iter(findParams);
					}
				}
				e.iter(findParams);

				var paramArray = [for (p in params) p];
				
				if (paramArray.length == 0) {				
					untyped Context.error(
						"No parameters found in lambda expression. Use _ for one parameter, _1 _2 for two, etc.", e.pos
					);
				}
				else {					
					paramArray.sort(function(x, y) return x.toString() > y.toString() ? 1 : 0);
					e = macro $a{paramArray} => $e;
				}
		}

		switch e.expr {
			case EBinop(OpArrow, e1, e2):
				// Extract lambda arguments [a,b] => ...
				var args = switch e1.expr {
					case EConst(CIdent(v)): [v];
					case EArrayDecl(values): [for (v in values) v.toString()];
					case _: untyped Context.error("Invalid lambda argument, use x => ... or [x,y] => ...", e1.pos);
				}
				
				// Test how many lambda arguments, then how many rest arguments
				return switch args.length {
					case 1: 
						var a = args[0];
						switch exprs.length {
							case 0: addExtension(macro function($a) return $e2);
							case 1: macro $fn(function($a) return $e2, ${exprs[0]});
							case 2: macro $fn(function($a) return $e2, ${exprs[0]}, ${exprs[1]});
							case 3: macro $fn(function($a) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]});
							case 4: macro $fn(function($a) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]}, ${exprs[3]});
							case _: untyped Context.error(restError, exprs[exprs.length - 1].pos);
						}
					case 2:
						var a = args[0], b = args[1];
						switch exprs.length {
							case 0: addExtension(macro function($a, $b) return $e2);
							case 1: macro $fn(function($a, $b) return $e2, ${exprs[0]});
							case 2: macro $fn(function($a, $b) return $e2, ${exprs[0]}, ${exprs[1]});
							case 3: macro $fn(function($a, $b) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]});
							case 4: macro $fn(function($a, $b) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]}, ${exprs[3]});
							case _: untyped Context.error(restError, exprs[exprs.length - 1].pos);
						}
					case 3:
						var a = args[0], b = args[1], c = args[2];
						switch exprs.length {
							case 0: addExtension(macro function($a, $b, $c) return $e2);
							case 1: macro $fn(function($a, $b, $c) return $e2, ${exprs[0]});
							case 2: macro $fn(function($a, $b, $c) return $e2, ${exprs[0]}, ${exprs[1]});
							case 3: macro $fn(function($a, $b, $c) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]});
							case 4: macro $fn(function($a, $b, $c) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]}, ${exprs[3]});
							case _: untyped Context.error(restError, exprs[exprs.length - 1].pos);
						}
					case 4:
						var a = args[0], b = args[1], c = args[2], d = args[3];
						switch exprs.length {
							case 0: addExtension(macro function($a, $b, $c, $d) return $e2);
							case 1: macro $fn(function($a, $b, $c, $d) return $e2, ${exprs[0]});
							case 2: macro $fn(function($a, $b, $c, $d) return $e2, ${exprs[0]}, ${exprs[1]});
							case 3: macro $fn(function($a, $b, $c, $d) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]});
							case 4: macro $fn(function($a, $b, $c, $d) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]}, ${exprs[3]});
							case _: untyped Context.error(restError, exprs[exprs.length - 1].pos);
						}						
					case _:
						untyped Context.error("Too many lambda arguments, max 4 supported.", e1.pos);
				}
			case _:
				return untyped Context.error("Lambda expression not in the form x => ...", e.pos);
		}
	}
}
