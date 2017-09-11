# 1.0.9

* Fixed the `selected` test in the `select` statement generator to convert both parts to string, then compare. As it was, a FixNum in the data obj failed to compare with a string in the options list.

# 1.0.8

* Changed the _:default_ added in 1.0.7 so that the _:default_ parameter itself doesn't show up in the output code.

# 1.0.7

* Added a _:default_ parameter to the opts in _checkbox_, _radio_, and _select_ controls to allow choosing a default without setting up a _obj_ parameter.
