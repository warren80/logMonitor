#######################################################################
# Program:  	Event Logger
# File:     	webout.rb
#		
# Functions:	create(table)
#
# Date: 	Mar 5, 2012
# Designer: 	Warren Voelkl
# Programmer: 	Warren Voelkl
#
# Notes:	creates a webpage called index.html which displays
#		the contents of the tabular data passed in
#######################################################################
class Webout
@@head = "<html>
<body>

<h1>Waza Logger Bad Person List</h1>

<table border=2>
<tr>
<td>Action</td><td>Internet Address</td><td>User</td><td>Date</td><td>Ban Length in seconds</td>
</tr>\n"

@@tail = "
</table>
</body>
</html>
"
  #####################################################################
  # Function:   create(table)
  # returns: 	void
  # Notes: 	opens a file named index.html and writes to file
  #####################################################################
  def Webout.create(table)
    f = File.new('index.html', 'w')
    f.puts @@head
    f.puts table
    f.puts @@tail
    f.close
  end
end

