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

  def Webout.create(table)
    f = File.new('index.html', 'w')
    f.puts @@head
    f.puts table
    f.puts @@tail
    f.close
  end
end

