'''
Try to:

minimize the number of print() function invocations by inserting the \n sequence into the strings

make the arrow twice as large (but keep the proportions)

duplicate the arrow, placing both arrows side by side; note: a string may be multiplied by using the following trick: "string" * 2 will produce "stringstring" (we'll tell you more about it soon)

remove any of the quotes, and look carefully at Python's response; pay attention to where Python sees an error - is this the place where the error really exists?

do the same with some of the parentheses;

change any of the print words into something else, differing only in case (e.g., Print) - what happens now?

replace some of the quotes with apostrophes; watch what happens carefully.

'''
#Original
print("The OG")
print("    *")
print("   * *")
print("  *   *")
print(" *     *")
print("***   ***")
print("  *   *")
print("  *   *")
print("  *****")

#Remove parenthesis including newline and sep
print("Arrow 1")
print("    *\n   * *\n  *   *\n *     *\n***   ***\n","  *   *\n"*2,"  *****",sep="")

#Use sep as new line
print("Arrow 2")
print("    *","   * *","  *   *"," *     *","***   ***","  *   *","  *   *","  *****",sep="\n")

print("Arrow 3")
print("    *",
"   * *",
"  *   *",
" *     *",
"***   ***",
"  *   *",
"  *   *",
"  *****",sep="\n")

# Duplicate arrow side by side
rep = 3
print("    *     "*rep)
print("   * *    "*rep)
print("  *   *   "*rep)
print(" *     *  "*rep)
print("***   *** "*rep)
print("  *   *   "*rep)
print("  *   *   "*rep)
print("  *****   "*rep)

#Making the arrow twice as large (Keeping the proportions)
print(" "," "," "," ","*")
print(" "," "," ","*"," ","*")
print(" "," ","*"," "," "," ","*")
print(" ","*"," "," "," "," "," ","*")
print("*","*","*"," "," "," ","*","*","*")
print(" "," ","*"," "," "," ","*")
print(" "," ","*"," "," "," ","*")
print(" "," ","*","*","*","*","*")

#Making the arrow twice as large (Keeping the proportions)
print("     *       ")            #<-- Had to add spaces before to correct distortion
print("    * *      ")            #<-- Had to add this line to correct distortion
print("   *"," *    ",sep=2*" ")   #<-- Add as many spaces as necessary inside sep argument
print("  * ","  *   ",sep=2*" ")
print(" *  ","   *  ",sep=2*" ")
print("*** ","  *** ",sep=2*" ")
print("  * ","  *   ",sep=2*" ")
print("  * ","  *   ",sep=2*" ")
print("  **","***   ",sep=2*"*")   #<-- Add as many "*" as necessary inside sep argument
 