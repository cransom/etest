
project:
A process where given a system description in a flake, run verification tests.
 - The system is ephemeral. It is possible for it to be self contained, but not required. (Future test situations may want to hook into external processes, databases, apis)
 - It will live in AWS, but can be tested on a linux host.
 - It reports status when done to a central host.


goals:

learn more about flakes versus the traditional setup
do further testing with ephemera
faster iteration on stateless AWS instances with ephemera


example testing setup:
run a service - check service alive
populate a database - check database up
report to a central authority with status
centralized logging
