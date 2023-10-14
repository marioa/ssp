#!/usr/local/bin/perl

use File::Copy;

$usage = "usage: changeNavigation.pl -n nav-file html-files...

<nav-file> is a file containing a list of URLs and text from which to
build the navigation bar.  The format is:

/project-url/file1.html,The Blah Page
/project-url/file2.html,Blah Results

";


while ($_ = shift @ARGV) {
   if (/^-n$/) {
      $nav = shift @ARGV;
      next;
   }
   if (/-h/ || /-\?/) {
      die $usage;
   }

   push(@files, $_);
}

die $usage if (!defined $nav);

print "Adding navigation bar from $nav\n\n";
open(NAV, $nav) || die "Cannot open $nav\n";

$navbar = "<table border=0 width=\"100%\">
<tr>
<td><center><font size='3'><b>\n";

while ($_ = <NAV>) {
   chop;
   ($url,$text) = split(",",$_);
   $navbar .= "[<a href='http://www.epcc.ed.ac.uk$url'>$text</a>]\n";
}
close(NAV);

$navbar .= "</b></font></center>
</td>
<!--
<TD ALIGN=\"right\" VALIGN=\"top\">
<IMG SRC=\"http://www.epcc.ed.ac.uk/ssp/images/summer2.gif\"
ALIGN=\"top\">
</TD>
-->
</TR>
</table>
";

$navbar = "<!-- BEGIN NAVIGATE -->\n$navbar\n<!-- END NAVIGATE -->\n";

#print $navbar;

foreach $file (@files) {

   print "$file...\n";

   # Valid file?
   if (! -f $file) {
      print "WARNING: $file does not exist\n";
      next;
   }

   # Skip symlinks
   if (-l $file) {
      print "WARNING: $file is a symlink; skipping\n";
      next;
   }

   # Create a backup of each file if we can
   if (! copy("$file", "$file.bak")) {
      print "WARNING: cannot create backup $file.bak; skipping\n";
      next;
   }

   if (! open(OLD, "$file.bak")) {
      print "WARNING: cannot open $file\n";
      next;
   }
   if (! open(NEW, ">$file")) {
      print "WARNING: cannot write to $file\n";
      close(OLD);
      next;
   }

   &addNav(OLD, NEW, $navbar);

   close(OLD);
   close(NEW);

}

######################################################################
sub addNav {
   my($fhOld, $fhNew, $navbar) = @_;

   my $page = "";
   while ($_ = <$fhOld>) {
      chop;
      $page .= $_ . "{{{";
   }

   $page =~ s/{{{<!-- BEGIN NAVIGATE.+{{{<!-- END NAVIGATE -->/\n$navbar\n/;
#   print $page;

   $page =~ s/{{{/\n/g;

   print $fhNew "$page";
}















