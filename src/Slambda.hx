import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ExprTools;
using StringTools;

// Auto-import Lambda when using Slambda
typedef SlambdaLambda = Lambda;

class Slambda {
	/**
	 * Lambda expressions! Syntax: 
	 * a.filter.fn(_ > 1)
	 * a.filter.fn(x => x > 1)
	 */
	public macro static function fn<T, T2>(fn : ExprOf<T -> T2>, restArgs : Array<Expr>) 
		return SlambdaMacro.f(fn, restArgs);
}

class Slambda1 {
	/**
	 * Lambda expressions! Syntax: 
	 * a.fold.fn(_1 + _2, 10)
	 * a.fold.fn([a,b] => a + b, 10)
	 */
	public macro static function fn<T, T2, T3>(fn : ExprOf<T -> T2 -> T3>, restArgs : Array<Expr>) 
		return SlambdaMacro.f(fn, restArgs);
}

class Slambda2 {
	/**
	 * Lambda expressions! Syntax: 
	 * a.yourfunc.fn("arg1", "arg2", _ != 0)
	 */
	public macro static function fn<T, T2, T3, T4>(fn : ExprOf<T -> T2 -> T3 -> T4>, restArgs : Array<Expr>) 
		return SlambdaMacro.f(fn, restArgs);
}

class Slambda3 {
	/**
	 * Lambda expressions! Syntax: 
	 * a.yourfunc.fn("arg1", "arg2", _ != 0, _1 < _2)
	 */
	public macro static function fn<T, T2, T3, T4, T5>(fn : ExprOf<T -> T2 -> T3 -> T4 -> T5>, restArgs : Array<Expr>) 
		return SlambdaMacro.f(fn, restArgs);
}

class Slambda4 {
	/**
	 * Lambda expressions! Syntax: 
	 * a.yourfunc.fn("arg1", some.variable, _ != 0, _1 < _2, "final argument")
	 */
	public macro static function fn<T, T2, T3, T4, T5, T6>(fn : ExprOf<T -> T2 -> T3 -> T4 -> T5 -> T6>, restArgs : Array<Expr>) 
		return SlambdaMacro.f(fn, restArgs);
}

private class SlambdaMacro {
	
	public static function f(fn : Expr, restArgs : Array<Expr>) {
		// If called through a static extension, fn contains the special "@:this this" expression:
		// http://haxe.org/manual/macro-limitations-static-extension.html
		var isExtension = fn.expr.match(EMeta({ name: ":this", params: _, pos: _}, {expr: EConst(CIdent("this")), pos: _}));

		if (isExtension) return {expr: ECall(fn, restArgs.map(createLambdaExpression.bind(true))), pos: fn.pos};
		
		// If not an extension, return only fn. Rest arguments won't make sense here.
		return restArgs.length == 0
			? createLambdaExpression(false, fn)
			: untyped Context.error('Rest arguments can only be used in static extensions.', restArgs[restArgs.length - 1].pos);
	}

	static var underscoreParam = ~/^_\d*$/;
	static var underscoreStringParam = ~/(?<!\$)\$(_\d*)\b/;
	static function createLambdaExpression(isExtension : Bool, e : Expr) : Expr {

		// If no arrow syntax, detect underscore parameters.
		switch e.expr {
			case EBinop(OpArrow, _, _):
			case _: 
				var params = new Map<String, Expr>();
				function findParams(e2 : Expr) {
					switch e2.expr {
						// Detect in single-quoted strings
						case EConst(CString(s)) if(e2.toString().startsWith("'") && e2.toString().endsWith("'")): 
							while (underscoreStringParam.match(s)) {
								var m = underscoreStringParam.matched(1);
								params.set(m, macro $i{m});
								s = underscoreStringParam.matchedRight();
							}
							e2.iter(findParams);
						case EConst(CIdent(v)) if (underscoreParam.match(v)):
							params.set(v, e2);
						case _:
							e2.iter(findParams);
					}
				}
				findParams(e);

				var paramArray = [for (p in params) p];
				
				if (paramArray.length > 0) {
					// If underscore parameters found, create an arrow syntax of the expression.
					// Sorted so the parameters are in the correct order in the function definition.
					paramArray.sort(function(x, y) return x.toString() > y.toString() ? 1 : 0);
					e = macro $a{paramArray} => $e;
				}
		}

		return switch e.expr {
			case EBinop(OpArrow, e1, e2):
				// Extract lambda arguments [a,b] => ...
				var lambdaArgs = switch e1.expr {
					case EConst(CIdent(v)): [v];
					case EArrayDecl(values) if(values.length > 0): [for (v in values) v.toString()];
					case _: untyped Context.error("Invalid lambda argument, use x => ... or [x,y] => ...", e1.pos);
				}
				
				{
					expr: EFunction(null, {
						ret: null,
						params: [],
						expr: macro return $e2,
						args: [for(arg in lambdaArgs) { name: arg, type: null, opt: false }]
					}),
					pos: e.pos
				};

			// If not an extension, it should return a non-lambda expression as a Void -> T function
			// to stay consistent with fn("x") <-> function() return "x".
			case _: isExtension ? e : macro function() return $e;
		}
	}
}
