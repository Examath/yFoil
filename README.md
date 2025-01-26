_**Note (27/01/2025): An easier to use web-based replacement for *yFoil* has been developed: See [SharpFoil](https://examath.github.io/SharpFoil/)**_

A MATLAB app that generates approximated equations of airfoils for use in Autodesk Inventor.

![image](https://github.com/Examath/yFoil/assets/26269676/539845ee-942d-49cb-896f-2b208a50fc58)

This program was designed to meet a unique challenge – parametrically adding airfoils to inventor. The current process of using splines is tedious and not parametric, whilst most other software that can do this is propietary. 

Instead, *yFoil* uses curve fitting to generate a pair of simpler equations that closely approximate any given airfoil. _yFoil_ supports generating any NACA 4-digit-series profile, or importing points in the _Lednicer_ format. These equations can then be copied into inventor.

_yFoil_ will no longer be updated as it has been superseeded by the web assembly application [SharpFoil](https://examath.github.io/SharpFoil/), which generates simpler equations and is easier to use. If you would still like to use yFoil, you can download either the standalone desktop installer or the MATLAB applet from [the lastest release](https://github.com/Examath/yFoil/releases/latest). See the [wiki](https://github.com/Examath/yFoil/wiki) for the user guide and how to use.
