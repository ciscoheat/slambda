import buddy.*;
using buddy.Should;

import Slambda.fn;
import utest.Assert;
using Slambda;

class Main implements Buddy<[Tests]> {}

class Tests extends BuddySuite
{	
	public function new() {
		describe("Slambda", {
			
			describe('one-argument functions', {
				it("can use a compact syntax with _ as parameter name", {
					var a = [1, 2, 3].filter.fn(_ > 1);
					a.should.containExactly([2, 3]);
				});

				it("can also use _1 instead of _ as parameter", {
					var a = [1, 2, 3].filter.fn(_1 > 1);
					a.should.containExactly([2, 3]);
				});

				it("can use arrow syntax without square brackets", {
					var a = [1, 2, 3].filter.fn(x => x > 1);
					a.should.containExactly([2, 3]);
				});

				it("can use arrow syntax with square brackets", {
					var a = [1, 2, 3].filter.fn([x] => x > 1);
					a.should.containExactly([2, 3]);
				});
			});

			describe('two-argument functions and more', {
				it("can use _1 and _2 as parameter names", {
					var a = [1, 1, 1].mapi.fn(_1 + _2);
					a.should.containExactly([1, 2, 3]);
				});

				it("can use _1 and _2 as parameter names in any order", {
					var a = ["1", "1", "1"].fold.fn(_2 + Std.parseInt(_1), 10);
					a.should.be(13);
				});

				it("can use arrow syntax with square brackets", {
					var a = [1, 1, 1].mapi.fn([i, a] => i + a);
					a.should.containExactly([1, 2, 3]);
				});
			});

			it("should pass rest arguments as parameters to the original function", {
				var a = [1, 1, 1].fold.fn([i, a] => i + a, 10);
				a.should.be(13);
				
				var b = [1, 1, 1].fold.fn(_1 + _2, 10);
				b.should.be(13);
			});

			it("should create lambda expression with rest arguments if an underscore is detected", {
				var attr = function(name : String, cb : String -> Int -> Dynamic) {
					name.should.be("test");
					cb("a", 1).should.be("a-1");
				}
				
				attr.fn("test", _1 + "-" + _2);
				attr.fn("test", [a,b] => a + "-" + b);
			});
			
			it("can be used without static extensions", {
				var b = [1, 1, 1].fold(fn([i, a] => i + a), 20);
				b.should.be(23);

				var c = [1, 2, 3].map(fn(Math.pow(_, 2)));
				c.should.containExactly([1, 4, 9]);

				var d = [1, 2, 3].map(fn(x => Math.pow(x, 2)));
				d.should.containExactly([1, 4, 9]);

				var e = [1, 2, 3].filter(fn(_ > 2));
				e.should.containExactly([3]);

				// Tests from thx.core
				Assert.same([2,3], [1,2].map(fn(_+1)));

				Assert.equals(0, fn((0))());
				Assert.equals(2, fn((_0))(2));
				Assert.equals(3, fn(_0+_1)(1,2));
				Assert.equals(6, fn(_0+_1+_2)(1,2,3));
				Assert.equals(10, fn(_0+_1+_2+_3)(1,2,3,4));
				Assert.equals(15, fn(_0+_1+_2+_3+_4)(1,2,3,4,5));

				Assert.equals(1, fn(Std.parseInt(_0))("1"));
				Assert.equals(1, fn(Std.parseInt(_))("1"));
				Assert.equals(1, fn(_0)(1));
				Assert.equals(3, fn(_0+_1)(1,2));
				Assert.equals(6, fn(_0+_1+_2)(1,2,3));
				Assert.equals(10, fn(_0+_1+_2+_3)(1,2,3,4));
				Assert.equals(15, fn(_0+_1+_2+_3+_4)(1,2,3,4,5));

				Assert.equals(1, fn(_)(1));
				Assert.equals(3, fn(_+_1)(1,2));
				Assert.equals(6, fn(_+_1+_2)(1,2,3));
				Assert.equals(10, fn(_+_1+_2+_3)(1,2,3,4));
				Assert.equals(15, fn(_+_1+_2+_3+_4)(1,2,3,4,5));				

				Assert.same(["1","2"], [1,2].map.fn("" + _));
				Assert.same(["1","2"], [1,2].map.fn('$_'));
				Assert.same(["X1","X2"], [1,2].map.fn('X$_'));
				Assert.same(["1X","2X"], [1,2].map.fn('${_}X'));
				Assert.same(["X2X","X4X"], [1,2].map.fn('X${_*2}X'));
			});

			it("should work chained and without extension methods", {
				var a = [1, 2, 3, 4, 5, 6].filter.fn(_ > 1).filter.fn(y => y > 2);
				a.should.containExactly([3, 4, 5, 6]);
				
				var b = a.filter(fn(_ > 3));
				b.should.containExactly([4, 5, 6]);

				var c = b.filter(fn(p => p > 4));
				c.should.containExactly([5, 6]);

				var d = c.filter(fn([q] => q > 5));
				d.should.containExactly([6]);
			});

			it("should have a natural syntax", {
				var persons = [
					{name: "A", email: "a@example.com"},
					{name: "B", email: null},
					{name: "C", email: null},
					{name: "D", email: "d@example.com"}
				];

				var emails = persons.filter.fn(_.email != null).map.fn(_.email);
				
				emails.should.containExactly(["a@example.com", "d@example.com"]);
			});
			
			it("should detect underscore parameters inside strings", {
				[1].map.fn('Test $_').should.containExactly(["Test 1"]);
				[1].map.fn('<b>$_</b>')[0].should.be("<b>1</b>");

				fn('$$_1')().should.be("$_1");
				fn('$_2$_1')("A", "B").should.be("BA");
				fn( { var _2a = 2; '$_2a$_1'; } )("1").should.be("21");
				fn("$_2$_1")().should.be("$_2$_1");
			});
			
			it("should handle nested lambda expressions properly", {
				var output = [[1, 2], [3, 4], [5, 6], [7, 8]].filter.fn(_.exists.fn(_ == 5));
				output.length.should.be(1);
				output[0].should.containExactly([5, 6]);
			});
		});
	}
}
