import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ExprTools;

// Auto-import Lambda
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
		if (exprs.length == 0) {
			untyped Context.error("No lambda expression specified for fn().", fn.pos);
		}
		else if (exprs.length-1 != expectedRest) {
			untyped Context.error('Invalid number of rest arguments, $expectedRest expected.', exprs[exprs.length - 1].pos);
		}

		var restError = "Too many rest arguments, max 4 supported.";
		var e = exprs.shift();
		
		switch e.expr {
			case EBinop(OpArrow, e1, e2):
				var args = switch e1.expr {
					case EConst(CIdent(v)): [v];
					case EArrayDecl(values): [for (v in values) v.toString()];
					case _: untyped Context.error("Invalid lambda argument, use x => ... or [x,y] => ...", e1.pos);
				}
				
				return switch args.length {
					case 1: 
						var a = args[0];
						switch exprs.length {
							case 0: macro $fn(function($a) return $e2);
							case 1: macro $fn(function($a) return $e2, ${exprs[0]});
							case 2: macro $fn(function($a) return $e2, ${exprs[0]}, ${exprs[1]});
							case 3: macro $fn(function($a) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]});
							case 4: macro $fn(function($a) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]}, ${exprs[3]});
							case _: untyped Context.error(restError, exprs[exprs.length - 1].pos);
						}
					case 2:
						var a = args[0], b = args[1];
						switch exprs.length {
							case 0: macro $fn(function($a, $b) return $e2);
							case 1: macro $fn(function($a, $b) return $e2, ${exprs[0]});
							case 2: macro $fn(function($a, $b) return $e2, ${exprs[0]}, ${exprs[1]});
							case 3: macro $fn(function($a, $b) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]});
							case 4: macro $fn(function($a, $b) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]}, ${exprs[3]});
							case _: untyped Context.error(restError, exprs[exprs.length - 1].pos);
						}
					case 3:
						var a = args[0], b = args[1], c = args[2];
						switch exprs.length {
							case 0: macro $fn(function($a, $b, $c) return $e2);
							case 1: macro $fn(function($a, $b, $c) return $e2, ${exprs[0]});
							case 2: macro $fn(function($a, $b, $c) return $e2, ${exprs[0]}, ${exprs[1]});
							case 3: macro $fn(function($a, $b, $c) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]});
							case 4: macro $fn(function($a, $b, $c) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]}, ${exprs[3]});
							case _: untyped Context.error(restError, exprs[exprs.length - 1].pos);
						}
					case 4:
						var a = args[0], b = args[1], c = args[2], d = args[3];
						switch exprs.length {
							case 0: macro $fn(function($a, $b, $c, $d) return $e2);
							case 1: macro $fn(function($a, $b, $c, $d) return $e2, ${exprs[0]});
							case 2: macro $fn(function($a, $b, $c, $d) return $e2, ${exprs[0]}, ${exprs[1]});
							case 3: macro $fn(function($a, $b, $c, $d) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]});
							case 4: macro $fn(function($a, $b, $c, $d) return $e2, ${exprs[0]}, ${exprs[1]}, ${exprs[2]}, ${exprs[3]});
							case _: untyped Context.error(restError, exprs[exprs.length - 1].pos);
						}						
					case _:
						untyped Context.error("Too many lambda arguments, max 4 supported.", e1.pos);
				}

			// Special case, one-argument function short syntax: .fn(x > 1)
			case _:
				var a = '_';
				
				function findVar(e : Expr) switch e.expr {
					case EConst(CIdent(v)) if(v != "this"): a = v;
					case _: e.iter(findVar);
				}
				e.iter(findVar);
				
				return switch exprs.length {
					case 0: macro $fn(function($a) return $e);
					case 1: macro $fn(function($a) return $e, ${exprs[0]});
					case 2: macro $fn(function($a) return $e, ${exprs[0]}, ${exprs[1]});
					case 3: macro $fn(function($a) return $e, ${exprs[0]}, ${exprs[1]}, ${exprs[2]});
					case 4: macro $fn(function($a) return $e, ${exprs[0]}, ${exprs[1]}, ${exprs[2]}, ${exprs[3]});
					case _: untyped Context.error(restError, exprs[exprs.length - 1].pos);
				}
		}
	}
}
