#!/usr/local/bin/perl

use File::Copy;

while ($_ = shift @ARGV) {
   push(@files, $_);
}

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

   &fix(OLD, NEW);

   close(OLD);
   close(NEW);

}

######################################################################
sub fix {
   my($fhOld, $fhNew) = @_;

   $contents = "";
   while ($_ = <$fhOld>) {
      $contents .= $_;
   }

   $contents =~ s/^<!-- END NAVIGATE -->[.\n]+^<!-- END NAVIGATE -->//;

   print $fhNew $contents;
}















