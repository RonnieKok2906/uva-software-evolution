# uva-software-evolution
Exercises for the master Software Engineering, Subject Software Evolution

Assignment 1
Using Rascal, design and build a tool that calculates the SIG maintainability model scores for a Java project.
Calculate at least the following metrics:
Volume,
Unit Size,
Unit Complexity,
Duplication.
For all metrics you calculate the actual metric values, for Unit Size and Unit Complexity you additionally calculate a risk profile, and finally each metric gets a score based on the SIG model (--, -, o, +, ++).
Calculate scores for at least the following maintainability aspects based on the SIG model:
Maintainability (overall),
Analysability,
Changeability,
Testability.
You can earn bonus points by also implementing the Test Quality metric and a score for the Stability maintainability aspect. 
Use this zip file to obtain compilable versions of two Java systems (smallsql and hsqldb): zip file
smallsql is a small system to use for experimentation and testing. Import as-is into Eclipse and ignore build errors.
hsqldb is a larger system to demonstrate scalability. Import into Eclipse, make sure to have only hsqldb/src on the build path, and add the following external jars from your eclipse/plugins/ directory: javax.servlet_$VERSION.jar and org.apache.ant_$VERSION/lib/ant.jar