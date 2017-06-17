# 1.0.4

* Added a `parms` argument to `alink` so that parameters that are being passed can be added as a hash. See the README.
* Added a test in specs to test the passing of parameters in `alink`.
* Updated the README and Notes.

# 1.0.3

* Updated the README and Notes.


# 1.0.2

* Renamed the 'session' variable to be 'usr'. It's become clear to me that the only way a script can access data passed from the controller to the script is through this variable: therefore, it ought to have a generic name. The variable usr will have whatever is passed in through `new` or `build`.

# 1.0.1

* Changed the `clear` method to return self so that clear can be chained.
* Corrected some of the comments above individual methods.
* Made some corrections and additions to the README.
* Made `write_html` a private method because it's only used by `to_html`.
* Added an argument to `build` and `initialize` to allow a session variable to be passed through.
* Corrected a problem with the `select` control in that the attributes were not being applied.
* Added a variable to `build` and `initialize` to be able to pass through a user argument. I called it `session` because that's what it would commonly be used for, but you could pass anything and access it in your Demeler code. For example, if you needed session _and_ some other variables, you would just pass them all in a Hash, including session.
* Added a .gitignore file.

# 1.0.0

* Initial version.
