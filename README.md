# MrBayes-Helper
Assists to extract useful information from MrBayes output files  
  
In this repository I prepared an R code which get a *pstat* file and returns two files.

- A log file in CSV format which contains NT for each position. It can detect positions which have more than one posibble NT and mark them. Aslo, it returns the probabilities of such positions so the user can investigate them.

- A text file which has the results based on the log file.


Try it here:  
1- Download the [sample file](https://raw.githubusercontent.com/khataei/MrBayes-Helper/master/asr_a3f_newworldmonkeys_gtr_outgroup_tree.pstat)


2- Go to https://seyedjavad.shinyapps.io/MrBayes-Helper/

3- Enter `newworldmonkeys` in the species-name box

4- Upload the file

5- Create the log file and result file
