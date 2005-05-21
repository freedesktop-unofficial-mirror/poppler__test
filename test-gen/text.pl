#!/usr/bin/perl

use Text::PDF::File;
use Text::PDF::Page;        # pulls in Pages
use Text::PDF::Utils;       # not strictly needed
use Text::PDF::SFont;
do "test-gen/image.inc";
$pdf = Text::PDF::File->new;            # Make up a new document
$root = Text::PDF::Pages->new($pdf);    # Make a page tree in the document
$root->proc_set("PDF", "Text");         # Say that all pages have PDF and Text instructions
$root->bbox(0, 0, 595, 840);            # hardwired page size A4 (for this app.) for all pages
$page = Text::PDF::Page->new($pdf, $root);      # Make a new page in the tree
$font = Text::PDF::SFont->new($pdf, 'Helvetica', 'F0');     # Make a new font in the document
$root->add_font($font);                                     # Tell all pages about the font

$page->add("q\n"); #saveState
$page->add("BT 1 0 0 1 200 600 Tm /F0 48 Tf 5 Tr (Hello World!) Tj ET\n");        # put some content on the page
my ($w,$h,$bpc,$cs,$img)=parseImage('test-gen/romedalen.ppm');
my $key='IMG1';
$xo=PDFDict();
$xo->{'Type'}=PDFName('XObject');
$xo->{'Subtype'}=PDFName('Image');
$xo->{'Name'}=PDFName($key);
$xo->{'Width'}=PDFNum($w);
$xo->{'Height'}=PDFNum($h);
$xo->{'Filter'}=PDFArray(PDFName('FlateDecode'));
$xo->{'BitsPerComponent'}=PDFNum($bpc);
$xo->{'ColorSpace'}=PDFName($cs);
$xo->{' stream'}=$img;
$pdf->new_obj($xo);
$root->{'Resources'}->{'XObject'}=PDFDict();
$root->{'Resources'}->{'XObject'}->{$key}=$xo;

$x = 100;
$y = 500;
$sx = $w;
$sy = $h;
$page->add(sprintf("%0.6f %0.6f %0.6f %0.6f %0.6f %0.6f cm\n", $sx,0,0,$sy,$x,$y));
$page->add("/$key Do\n");
$page->add("Q\n"); #restoreState
$page->add("0 0 34 rg\n");
$page->add("BT 1 0 0 1 100 600 Tm /F0 48 Tf 0 Tr (Hello World!) Tj ET");        # put some content on the page

$pdf->out_file($ARGV[0]);   # output the document to a file

# all done!
