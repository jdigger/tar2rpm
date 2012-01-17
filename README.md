Purpose
=======

This provides an easy way to create RPM files.


Setup
======

Assuming you have [the Ruby Version Manager (RVM)](https://rvm.beginrescueend.com/) installed, most of the environmental stuff is handled for you.  If RVM is not installed, the "guaranteed to be current" version of Ruby this is tested with can be found at the top of the .rvmrc file, and the list of gems (and their versions) can be found in .gems.

The program to run is `bin/tar2rpm`.  Running it with no options, or -h, will provide a description of the options.

The tests are written for RSpec 2.
