
package TEMPL;

use GD;

sub SizeInfoForImage {
    my ($str) = @_;

    if($str =~ /shim/i) {
        return "";
    }

    unless($str =~ m#src=(\S+)#i) {
        return "";
    }
    my $file = $1;
    $file =~ s/"//g;
    $file =~ s#.*/##;
    $file = "pics/$file";

    my $img = GD::Image->new($file);
    defined($img) or return "";

    my ($width, $height) = $img->getBounds();

    return qq|width="$width" height="$height"|;
}

if(defined $ENV{'HTML'}) {
    $HTML = 1;
    $PL = 'html';
} else {
    $HTML = 0;
    $PL = 'pl';
}
if(defined $ENV{'VERSION'}) {
    $VERSION = $ENV{'VERSION'};
}

@TOC = (
    [ 'Examples',   "examples",   0 ],
    [ 'Tutorials',  "tutorial",   0 ],
    [ 'Features',   "features",   0 ],
    [ 'Download',   "download",   0 ],
    [ 'Reference',  "ref",        0 ],
    [ 'Technology', "tech",       0 ],
    [ 'Library',    "library",    0 ],
    [ 'Forum',      "forum",      0 ],
    [ 'Contact',    "contact",    0 ],
);
$TOC = '';
for (@TOC) {
    my ($title, $link, $where) = @{ $_ };

    if($where and not($0 =~/tutorial|bracket/)) {
        next;
    }
    $toc = $where ? "tocsub" : "toc";

    if($0 =~ /$link\.pl$/) {
        $TOC .= qq#
            <div class="$toc">
                $title
            </div>
        #;
    } else {
        $TOC .= qq#
            <div class="$toc">
                <a class="toc" href="$link.$PL">$title</a>
            </div>
        #;
    }
}

$sp = "&nbsp;" x 20;
$sp2 = "&nbsp;" x 4;
$SEP = qq{<p style="text-align: center;">*$sp*$sp*$sp2</p>};


$TOP = qq|
<!DOCTYPE html>

<head>
    <title>$main::TITLE</title>
    <link rel="stylesheet" type="text/css" href="style.css">
    <script type="text/javascript" src="support.js"></script>
$main::ADD_TO_HEAD
</head>

<body $main::ADD_TO_BODY>
|;

$BOTTOM = qq|
<div class="copyouter">
<div class="copyfooter">
    &copy; 2008-2016 SolveSpace contributors. Most recent update Oct 16 2016.
</div>
</div>
</body>
|;

sub OutputWithHeader {
    my ($title, $text) = @_;

    if(defined $main::SHOW_VERSION && defined $VERSION) {
        $version = qq|<span class="version"> (for $VERSION)</span>|;
    }

    Output(qq|
<div class="header">
    <a class="header_big" href="index.$PL">
        <span class="header_big">SOLVESPACE</span>
        <span class="header_little"> -- parametric 2d/3d CAD</span>
    </a>
</div>

<div class="tocbox">
    $TEMPL::TOC
</div>
<div class="main">
    <div class="subtitle">$title$version</div>
    $text
</div>
|);
}


sub Output {
    my ($str) = @_;

    $str =~ s[<(\s*img[^>]+)>][
        sub {
            my $v = $1;
            $v =~ s#/\s*$##;
            if($v =~ /(width|height)\s*=/i) {
                return "<$v>";
            } else {
                $extra = SizeInfoForImage($v);
                return "<$v $extra>";
            }
        }->();
        ]iseg;

    if(!$HTML) {
        print "Content-Type: text/html; charset=utf-8\n";
    }
    print $TOP . $str . $BOTTOM;
}

1;
