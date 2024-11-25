#import "@preview/charged-ieee:0.1.0": ieee

#show: ieee.with(
  title: [Agda Linear Algebra],
  abstract: [

  ],
  authors: (
    (
      name: "Guilherme Horta Alvares da Silva",
      // department: [Formal Methods],
      organization: [Chalmers University],
      location: [Gothenburg, Sweden],
      email: "alvares@chalmers.se"
    ),
  ),
  index-terms: ("Agda", "Linear-Algebra"),
  bibliography: bibliography("refs.bib"),
)

#show link: underline
#let websiteRoot = "https://guilhermehas.github.io/agda-linear-algebra/"
#let web(ext, row, content) = link((websiteRoot, ext, ".html", "#", str(row)).join(), content)

= Introduction
The main purpose of linear algebra in Agda is to solve linear systems of equations. For example:
$ x + y = 3 \
  x - y = 1 $
After solving, the solution will be $x = 2 and y = 1$.

There are three cases for a solution of a system of equations.
The most common is the previous one when each variable has one unique value.
The second case is when there is no solution for a system of equations. For example:
$ x = 0 \
  x = 1 $
It is impossible that $x$ has two different values.

The last case is the under-specified system of equations. For example:
$ x - y = 0 $ <same>
In that case, the set of all solutions can be expressed as:
$ vec(x, y) = k dot vec(1, 1) $ <vecK>

A solution $x = 1 and y = 1$ can be found when $k = 1$.

In the #web("Examples.Paper", 292)[library], after solving a linear system of equations in the simplest case,
the function returns its solution (a vector of rational numbers).
This function is a dependent typed function, so it returns the vector of solution if there is one, 
but returns unit type if there is no solution or if there are many possible solutions.

= Overview

== Gaussian Elimination
The linear system of equations is represented as a matrix,
and the library uses a Gaussian elimination to find the solution in the matrix form.
For example, from this system of equations:

$ x + y = 3 \
  x - y = 1 $
we have the matrix and the vector:
$ A = mat(1, 1; 1, -1) space b = vec(3, 1) $
such that
$ A dot v = b$.

#set math.mat(augment: (vline: 2, stroke: (dash: "dashed")))

The library append $A$ and $b$ in that way:
$ A|b = mat(1,1,3; 1,-1,1)  $
The first step of Gauss Elimination is performed by subtracting the second line from the first.
So the new system of equations becomes:
$ mat(1,1,3; 0,-2,-2) $

This matrix already has a triangle of zeros in the down left and it is necessary to have the triangle of zeros in the upper right also.
To achieve this, adding half of the second row to the first one is necessary.

$ mat(1,0,2; 0,-2,-2) $

In the last step, the second row is divided by minus two, so the new matrix is an identity matrix.

$ A'|b' = mat(1,0,2; 0,1,1) $

After normalizing $A$, the library reads of the solution of the linear system of equations as the
vector $vec(2, 1)$.

== Vector Space
After each step of the Gaussian elimination, the #web("Algebra.Module.Definition", 893)[ span ]
(it is composed for all points that a list of vectors can reach by adding and multiplication) of the rows of $A|b$ is preserved.
That means that:
$ "span"(A|b) ≋^v "span"(A'|b') $

With that property, it is possible to prove that the normalized matrix's solution is the same as the original matrix.
It is necessary to have both sides of the implication because it is also necessary to prove that all the solutions of the original matrix
are also solutions to the new matrix.

#set math.mat(augment: {})

= Data types

== Vectors and Matrixes
Most of the code base is done using functional vectors and functional matrices.
The type of #web("Data.Vec.Functional", 1232)[Vectors] is defined as $ "Vector" A space n = "Fin n" -> A $
The type of #web("Algebra.Matrix.Base", 397)[matrices] is: $ "Matrix A n m" = "Vector (Vector A m) n" $
where *n* is the number of rows and *m* is the number of columns.

Note that $M$ has type $"Matrix A n m"$, i:th row of M is accessed by function application, $M i$ has type $"Vector A m"$
and finally, $M i j$ is column j's element in this row and has type A.
For more explanations of functional definitions, look at @fdef.

== Underlying scalars
In Gaussian elimination, the type of the elements is a Field defined in the Agda Standard Library.
As in the standard library field definition, we use setoids to handle equalities.
For more explanations about setoids, look at @setoids.

== #web("Algebra.Module.Definition", 1079)[ Vector Space span relation ]
In the library, there is the vector space relation which means that two lists of vectors span the same vector space.
Two lists of vectors have the same vector space if both of them can reach the same element.

== #web("Algebra.Module.VecSpace", 3520)[ Vector Space sub-relation ]
In the first stage of the Gauss elimination, there are just two operations.
Swapping two lines, and subtracting a multiple of one row from another.
These operations preserve the span generated by the rows of the matrix.

For example, the matrix A has two rows corresponding to a vector.
$ A = mat(1, 0, 1; 2, 1, 2) , v_1 = vec(1, 0, 1), v_2 = vec(2, 1, 2) $

After swapping, the rows of the matrix, the new matrix becomes:
$ A' = mat(2, 1, 2; 1, 0, 1) , v'_1 = v_2, v'_2 = v_1 $

Another operation that can be done is subtracting two times the first row from the second row.

$ A'' = mat(1, 0, 1; 0, 1, 0), v''_1 = v_1, v''_2 = v_2 - 2 * v_1 $

= Algorithm

== Left-down triangle
The algorithm starts by choosing a row from the beginning of the matrix to the end.
The row is of type *Fin n* where *n* is the number of rows of the matrix.
After picking this first row, a row between the successor of the first row and the end of the matrix is chosen.
For this algorithm to work, it is necessary to prove the well-founded choice of these pivots to do the recursion.

After choosing the two pivots, there are 3 cases to choose from, comparing the positions of the first pivot with the second one.
- If the first is less than the second one, nothing is done because it is already what we want. Ex:
$ mat(1, 2; 0, 3) $
- If the position of the first pivot is the same as the second one,
  it is necessary to subtract the second row by a multiple of the first one.
  After that, the position of the second pivot should increase because it should be zero in the value of the previous pivot position. Ex:
$ mat(1, 2; 1, 3) => mat(1, 2; 0, 1) $
- If the position of the second pivot is greater than the first one, the algorithm swaps the two rows. Ex:
$ mat(0, 1; 2, 3) => mat(2, 3; 0, 1) $

The matrix after these steps is with a triangle of zeros in the left and down part.
So, the next step is to make a triangle of zeros in the upper and right parts of the matrix.
The algorithm for this part is simpler than the last one because it is not necessary to swap rows anymore.
In addition, the position of the pivots does not change because subtracting an upper row from a lower row
does not change the zeros of left down triangle.

$ mat(
  1, 2, ..., 2, 3;
  0, 2, ..., 4, 6;
  dots.v, dots.v, dots.down, dots.v, dots.v;
  0, 0, ..., 0, 2;
  0, 0, ..., 0, 0;
) $

After applying the algorithm, the matrix is almost normalized.
So, the next step is to remove all rows of only zeros.
It can be done because it does not change the vector space generated by these rows.

$ mat(
  1, 2, ..., 2, 3;
  0, 2, ..., 4, 6;
  dots.v, dots.v, dots.down, dots.v, dots.v;
  0, 0, ..., 0, 2;
) $

In the last step, the algorithm divides each row for the value of the pivot.
So, the value of each pivot becomes one.

$ mat(
  1, 2, ..., 2, 3;
  0, 1, ..., 2, 3;
  dots.v, dots.v, dots.down, dots.v, dots.v;
  0, 0, ..., 0, 1;
) $

In all the steps of these algorithms, I proved that the vector space is preserved.
So the algorithm generates a normalized matrix with the same vector space as the original one.

== Upper-right triangle

The last step is to create some zeros by normalizing from down to up. For example:
$ mat(1, 2, 1; 0, 0, 1) => mat(1, 2, 0; 0, 0, 1) $ <MNormed>

The matrix formed by only the columns of the pivots is the identity matrix.
And the new matrix has this axiom:
$ forall i, i', j in "Fin 2" | i eq.not i' and "isPivot"(i, j) \
  =>  M' i' j = 0  $ <norm>

By applying @norm to @MNormed with $i = 1, i' = 0, j = 2$,
we have $"isPivot"(1, 2) = "true"$ and $M'[0][2] = 0$ as expected.

= Solving from normalized matrix

== Vector space property
The rows of the normalized matrix have the same vector space as the rows of the original matrix.
This means that all solutions in the normalized matrix are the same as those in the original one.
In addition, all solutions of the original matrix are also solutions of the normalized matrix.

When the normalized matrix does not have any solution,
it means that the original matrix also does not have any solution.

In conclusion, solving the system of normalized matrix is the same as solving the system of the original one.

== Identity Matrix
The case of the identity matrix is the simplest one.
Each row is the solution of a variable.
The last column has the solution of all variables.

== Triangle zeros matrix
In the triangle zero matrix, the left and below side just have zero values.

Each row of the matrix is the solution of a variable that corresponds to the pivot position of that row.
The variables that are not in the pivot position of any row are free variables,
which means that they can have any value.

In the end, each variable has a parametrized solution and I proved using all the rows of the matrix that
this parametrized solution is valid in all of the equations.
In addition, I proved that all solutions can be expressed by the parametrized solution,
which means that it is the most generous one.

= Discussion

== Functional definition <fdef>
Using the functional definition instead of the conventional data-typed definition helps with index manipulation.
However, it isn't good most of the time.
For example, type inference works better when using data-typed definitions.

== Setoids <setoids>
In this library, it is necessary because vectors and matrixes are defined in a functional way.
However, if it is defined in the data way, setoids would just increase the complexity without any gains.

== Vector Space
The implementation of the #web("Algebra.Module.Definition",1079)[  vector space ] uses #web("Algebra.Module.Bundles", 2658)[ Left Module ].
Each row of the matrix is a #web("Algebra.Module.Instances.FunctionalVector", 3932)[ vector ] that is an element of Left Module.

= Future Work
I should prove that the vectors that create the parametrized solution should be linearly independent.
