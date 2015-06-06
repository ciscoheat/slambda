import buddy.*;
using buddy.Should;

import Slambda.fn;
using Slambda;

class Main implements Buddy<[Tests]> {}

class Tests extends BuddySuite
{	
	public function new() {
		describe("Slambda", {
			
			describe('one-argument functions', {
				it("can use a very compact syntax", {
					var a = [1, 2, 3].filter.fn(i > 1);
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
				it("can only use arrow syntax with square brackets", {
					var a = [1, 1, 1].mapi.fn([i, a] => i + a);
					a.should.containExactly([1, 2, 3]);
				});
			});
			
			it("should pass rest arguments as parameters to the original function", {
				var a = [1, 1, 1].fold.fn([i, a] => i + a, 10);
				a.should.be(13);

				var b = Slambda1.fn([1, 1, 1].fold, [i, a] => i + a, 20);
				b.should.be(23);
			});

			it("should work chained and without extension methods", {
				var a = [1, 2, 3, 4, 5, 6].filter.fn(x > 1).filter.fn(y => y > 2);
				a.should.containExactly([3, 4, 5, 6]);
				
				var b = fn(a.filter, z > 3);
				b.should.containExactly([4, 5, 6]);

				var c = fn(b.filter, p => p > 4);
				c.should.containExactly([5, 6]);

				var d = fn(c.filter, [q] => q > 5);
				d.should.containExactly([6]);
			});

			it("should have a natural understandable syntax", {
				var persons = [
					{name: "A", email: "a@example.com"},
					{name: "B", email: null},
					{name: "C", email: null},
					{name: "D", email: "d@example.com"}
				];

				var emails = persons.filter.fn(person.email != null).map.fn(person.email);
				
				emails.should.containExactly(["a@example.com", "d@example.com"]);
			});
		});
	}
}
