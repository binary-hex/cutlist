## MIT License

## Copyright (c) 2022 binary-hex

## Permission is hereby granted, free of charge, to any person
## obtaining a copy of this software and associated documentation
## files (the "Software"), to deal in the Software without
## restriction, including without limitation the rights to use, copy,
## modify, merge, publish, distribute, sublicense, and/or sell copies
## of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:

## The above copyright notice and this permission notice shall be
## included in all copies or substantial portions of the Software.

## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
## EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
## MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
## NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
## BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
## ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.



# INPUT
stock = 100; # length of your stock
elements = [30 40 60 80]'; # length of required segments
order = [3 5 5 1]'; # number of pieces




elements_len = length(elements);
order_len = length(order);

if (elements_len != order_len)
  error("elements_len != elements_len, check your input")
endif

shortest_in_stock = floor(stock / min(elements));

cart  = nthargout([1:elements_len], @ndgrid, [0:shortest_in_stock]);
combinations = cell2mat(cellfun (@(c) c(:), cart, "UniformOutput", false));

filtered = combinations(combinations * elements <= stock, :);
filtered_len = length(filtered);

cost = stock - filtered * elements;

lb = zeros(1, filtered_len);
ub = max(order) * ones(1, filtered_len); # upper bound is max value in the order list
ctype = char("S" * ones(elements_len, 1));
vartype = char("I" * ones(filtered_len, 1));
sense = 1;

[xopt, fmin, errnum, extra] = glpk(cost, filtered', order, lb, ub, ctype, vartype, sense)

found_cut_patterns = filtered(xopt > 0, :);
found_cut_patterns_numbers = xopt(xopt > 0, :);

if (rows(found_cut_patterns) != length(found_cut_patterns_numbers))
  error("number of found cut patters is off")
endif


offcuts = stock - found_cut_patterns * elements

# print solution
spaces_in_tab = 8;
for iter = 1:1:elements_len
  printf("%d\t", elements(iter));
endfor
  printf("| offcut\t| number of cut patters\t\n")
  printf("%s|\n", char("-" * ones(elements_len * spaces_in_tab, 1)))

for row = 1:1:rows(found_cut_patterns)
  for col = 1:1:columns(found_cut_patterns)
    printf("%d\t", found_cut_patterns(row, col));
  endfor
    printf("| %d\t\t| %d\n", offcuts(row), found_cut_patterns_numbers(row))
endfor
printf("sum of offcuts: %d\n", fmin)
printf("number of required timbers: %d\n", sum(found_cut_patterns_numbers))
