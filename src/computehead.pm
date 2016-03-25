package computehead;
use feature_filter;
use shakti_tree_api;
use Exporter qw(import);

our @EXPORT = qw(computehead);

sub copy_np_head
{
	my $sent=@_[0];

	copy_head_np("NP",$sent);

	copy_head_np("JJP",$sent);
	copy_head_np("CCP",$sent);
	copy_head_np("RBP",$sent);
	copy_head_np("BLK",$sent);
	copy_head_np("NEGP",$sent);
	copy_head_np("FRAGP",$sent);
	copy_head_np("NULL__CCP",$sent);
	copy_head_np("NULL__NP",$sent);
	#print_tree();
}	#End of Sub

sub copy_vg_head
{
	my $sent=@_[0];

	copy_head_vg("VGF",$sent);
	copy_head_vg("VGNF",$sent);
	copy_head_vg("VGINF",$sent);
	copy_head_vg("VGNN",$sent);
	copy_head_vg("NULL__VGNN",$sent);
	copy_head_vg("NULL__VGF",$sent);
	copy_head_vg("NULL__VGNF",$sent);
}

sub copy_head_np
{
	my ($pos_tag)=$_[0];	#array which contains all the POS tags
	my ($sent)=$_[1];	#array in which each line of input is stored
	my %hash=();
	if($pos_tag =~ /^NP/)
	{
		$match = "NN"; #Modified in version 1.4
			       #For NST
	}
	if($pos_tag =~ /^V/ )
	{
		$match = "V";
	}
	if($pos_tag =~ /^JJP/ )
	{
		$match = "J";
	}
	if($pos_tag =~ /^CCP/ )
	{
		$match = "CC";
	}
	if($pos_tag =~ /^RBP/ )
	{
		$match = "RB";
	}
	my @np_nodes = get_nodes(3,$pos_tag,$sent);#gives the nodes at which each pos_tag tag matches(index of chunk start)
	
	for($i=$#np_nodes;$i>=0;$i--)
	{	
		my (@childs)=get_children($np_nodes[$i],$sent);#gives the nodes(index) at which childs(words in a chunk) are found
		$j = $#childs;
		while($j >= 0)
		{
			#$f1=node id in decreasing order
			#$f2=tokens(words) in dec order
			#$f3=word tags
			#$f4=feature structure
#			print "$childs[$j]"."\n";				"--"."@sent"."\n";
			my($f0,$f1,$f2,$f3,$f4)=get_fields($childs[$j],$sent);
			$word=$f2;
#			print "--".$f4,"---\n";
			$f4=~s/\//&sl/;
			my ($x,$f4)=split(/</,$f4);
			my ($f4,$x)=split(/>/,$f4);
			$f4=~s/</&angO/;
			$f4=~s/>/&angC/;
			$f4="<".$f4.">";
#			print "3 start head>>".$f4."<<\n";
			my $fs_ref = read_FS($f4);
#			print "3 end head\n";
                        my @name_val = get_values("name", $fs_ref);
			
#print "$word"."\n";
			if($f3 eq "PRP") ##to make sure that the pronouns are identified correctly
			{
				$f3 = "NN";
			}

			if($f3 eq "WQ") ##to make sure that the pronouns are identified correctly
			{
				$f3 = "NN";
			}

			if($f3=~/^$match/)
			{
				if($hash{$f2} eq "")
				{
					$hash{$word}=1;
				}
				elsif($hash{$f2} ne "")
				{
					$hash{$word}=$hash{$word}+1;
				}
				$id=$hash{$word};
				my ($x,$y)=split(/>/,$f4);
				$x =~ s/ name=[^ >]+//;
				if($id==1)
				{
					$att_val="$word";
				}
				elsif($id!=1)
				{
					$att_val="$word"."_"."$id";
				}
				
				#$new_fs = $x." head=\"$name_val[0]\">";
				$new_fs = $x." head=$name_val[0]>";
				#my $new_head_fs=$x." name=\"$att_val\">";
				#modify_field($childs[$j],4,$new_head_fs,$sent);
				last;
			}
			elsif($j == 0)
			{
				
				my($f0,$f1,$f2,$f3,$f4)=get_fields($childs[$#childs],$sent);
				#-----------------modifications to handle PRP and PSP case------------------
				$change=$#childs;	

			$f4=~s/\//&sl/;
			my ($x,$f4)=split(/</,$f4);
			my ($f4,$x)=split(/>/,$f4);
			$f4=~s/</&angO/;
			$f4=~s/>/&angC/;
			$f4="<".$f4.">";
				while(1)
				{
					if($f3 eq "PSP" or $f3 eq "PRP")
					{
						$change=$change-1;
						if($childs[$change] eq "") 	##Modifications per Version 1.3
						{				##To handle NP chunks with single PSP
							$change=$change+1;	##
							last;			##
						}
						($f0,$f1,$f2,$f3,$f4)=get_fields($childs[$change],$sent);
					}
					else
					{
						last;
					}
				}

				
				$new_fs = $f4;
				$word=$f2;
				my $fs_ref = read_FS($f4);
                                my @name_val = get_values("name", $fs_ref);

				if($hash{$f2} eq "")
				{
					$hash{$word}=1;
				}
				elsif($hash{$f2} ne "")
				{
					$hash{$word}=$hash{$word}+1;
				}
				$id=$hash{$word};
				#--------------------------------------------------------------------------------
				my ($x,$y)=split(/>/,$f4);
				$x =~ s/ name=[^ >]+//;
				if($id==1)
				{
					$att_val="$word";
				}
				elsif($id!=1)
				{
					$att_val="$word"."_"."$id";
				}
				#$new_fs = $x." head=\"$name_val[0]\">";
				$new_fs = $x." head=$name_val[0]>";
				#my $new_head_fs=$x." name=\"$att_val\">";
				#modify_field($childs[$change],4,$new_head_fs,$sent);
			}
			$j--;
		}
		($f0,$f1,$f2,$f3,$f4) = get_fields($np_nodes[$i],$sent);
		if($f4 eq '')
		{
			##print "1check ---$new_fs\n";
			modify_field($np_nodes[$i],4,$new_fs,$sent);

			($f0,$f1,$f2,$f3,$f4) = get_fields($np_nodes[$i],$sent);
			$fs_ptr = read_FS($f4,$sent);
			#print "---x--$x\n";
			#add_attr_val("name",$head_att_val,$fs_ptr,$sent);
			($f0,$f1,$f2,$f3,$f4) = get_fields($np_nodes[$i],$sent);

			#print "2check ---$f4\n";
			
		}
		else
		{
			$fs_ptr = read_FS($f4,$sent);
			$new_fs_ptr = read_FS($new_fs,$sent);
			merge($fs_ptr,$new_fs_ptr,$sent);
			$fs_string = make_string($fs_ptr);
			modify_field($np_nodes[$i],4,$fs_string,$sent);
			($f0,$f1,$f2,$f3,$f4) = get_fields($np_nodes[$i],$sent);
			$fs_ptr = read_FS($f4,$sent);
			#add_attr_val("name",$head_att_val,$fs_ptr,$sent);

#modify_field($np_nodes[$i], 4, $head_att_val,$sent);
		}
	}
	#print "hiii--\n"
	#print_tree();
	#print "hiii\n";
}

#AddID($ARGV[0]);
sub copy_head_vg
{
	my($pos_tag) = $_[0];	#array which contains all the POS tags
	my($sent) = $_[1];	#array in which each line of input is stored

	my %hash=();
	if($pos_tag =~ /^NP/)
	{
		$match = "N";
	}
	if($pos_tag =~ /^V/ )
	{
		$match = "V";
	}
	if($pos_tag =~ /^JJP/ )
	{
		$match = "J";
	}
	if($pos_tag =~ /^CCP/ )
	{
		$match = "CC";
	}
	if($pos_tag =~ /^RBP/ )
	{
		$match = "RB";
	}
	

	@np_nodes = get_nodes(3,$pos_tag,$sent);
	for($i=$#np_nodes; $i>=0; $i--)
	{
		my(@childs) = get_children($np_nodes[$i],$sent);
		$j = 0;
		while($j <= $#childs)
		{
			#$f1=node id in decreasing order
			#$f2=tokens(words) in dec order
			#$f3=word tags
			#$f4=feature structure

			my($f0,$f1,$f2,$f3,$f4) = get_fields($childs[$j],$sent);
			$word=$f2;
			$f4=~s/\//&sl/;
			my ($x,$f4)=split(/</,$f4);
			my ($f4,$x)=split(/>/,$f4);
			$f4=~s/</&angO/;
			$f4=~s/>/&angC/;
			$f4="<".$f4.">";
			if($f3 =~ /^$match/)
			{
				$new_fs = $f4;

				my $fs_ref = read_FS($f4);	#feature structure is sent to function where all the categories are dealt
                                my @name_val = get_values("name", $fs_ref);

				if($hash{$f2} eq "")
                                {
                                        $hash{$word}=1;
                                }
                                elsif($hash{$f2} ne "")
                                {
                                        $hash{$word}=$hash{$word}+1;
                                }
                                $id=$hash{$word};
                                my ($x,$y)=split(/>/,$f4);
				$x =~ s/ name=[^ >]+//;
				if($id==1)
                                {
                                        $att_val="$word";
                                }
                                elsif($id!=1)
                                {
                                        $att_val="$word"."_"."$id";
                                }
			
				#$new_fs = $x." head=\"$name_val[0]\">";
                                $new_fs = $x." head=$name_val[0]>";
                                #my $new_head_fs=$x." name=\"$att_val\">";
                                #modify_field($childs[$j],4,$new_fs,$sent);
				last;
			}
			elsif($j == 0)
			{
				my($f0,$f1,$f2,$f3,$f4) = get_fields($childs[$#childs],$sent);
				$word=$f2;
			$f4=~s/\//&sl/;
			my ($x,$f4)=split(/</,$f4);
			my ($f4,$x)=split(/>/,$f4);
			$f4=~s/</&angO/;
			$f4=~s/>/&angC/;
			$f4="<".$f4.">";

				my $fs_ref = read_FS($f4);
                                my @name_val = get_values("name", $fs_ref);

				if($hash{$f2} eq "")
                                {
                                        $hash{$word}=1;
                                }
                                elsif($hash{$f2} ne "")
                                {
                                        $hash{$word}=$hash{$word}+1;
                                }
                                $id=$hash{$word};

                                my ($x,$y)=split(/>/,$f4);
				$x =~ s/ name=[^ >]+//;

				if($id==1)
                                {
                                        $att_val="$word";
                                }
                                elsif($id!=1)
                                {
                                        $att_val="$word"."_"."$id";
                                }
			
				#$new_fs = $x." head=\"$name_val[0]\">";
                                $new_fs = $x." head=$name_val[0]>";
                                #my $new_head_fs=$x." name=\"$att_val\">";
                                #modify_field($childs[$#childs],4,$new_fs,$sent);
			}
			$j++;
		}
		($f0,$f1,$f2,$f3,$f4) = get_fields($np_nodes[$i],$sent);
		if($f4 eq '')
		{
			modify_field($np_nodes[$i],4,$new_fs,$sent);
		}
		else
		{
			$fs_ptr = read_FS($f4,$sent);
			$new_fs_ptr = read_FS($new_fs,$sent);
			merge($fs_ptr,$new_fs_ptr,$sent);
			$fs_string = make_string($fs_ptr,$sent);
			modify_field($np_nodes[$i],4,$fs_string,$sent);

		}
	}
}

sub make_chunk_name
{
	my($i, @leaves, $new_fs, @tree, $line, $string, $file, @lines, @string2, $string_ref1, $string1, $string_name);

	$input = $_[0];
	my %hash_index;
	my %hash_chunk;
	my @final_tree;
#read_story($input);
	my @tree = get_children(0, $input);
	my $ssf_string = get_field($tree[0], 3, $input);
	if($ssf_string eq "SSF")
	{
		@final_tree = get_children(1, $input);
	}
	else
	{
		@final_tree = @tree;
	}
	my $k, $index=0, $count=0, $index_chunk=0;
	@tree = get_children($s,$input);
	foreach $i(@final_tree)
	{
		$string = get_field($i, 4,$input);
		@leaves = get_children($i,$input);
		my $string_fs = read_FS($string, $input);

		foreach $m(@leaves)
		{
			$string1 = get_field($m, 4,$input);
			$string_fs1 = read_FS($string1, $input);


			$new_fs = make_string($string_fs1, $input);
			modify_field($m, 4, $new_fs, $input);
		}
	}

	foreach $i(@final_tree)
	{
		my $count_chunk=0;
		$index_chunk++;
		$string = get_field($i, 4, $input);
		$string_fs = read_FS($string, $input);

		my @old_value_name = get_values("name", $string_fs, $input);
		#print @old_value_name,"\n";
		if($old_value_name[0]=~/\'/ or $old_drel[0]=~/\"/)
		{
			$old_value_name[0]=~s/\'//g;
			$old_value_name[0]=~s/\"//g;
		}

		my @chunk = get_field($i, 3, $input);
		for ($ite1=1; $ite1<$index_chunk; $ite1++)
		{
			my $actual_chunk_name = $hash_chunk{$ite1};
			my @chunk_name_split = split(/__/, $actual_chunk_name);
			if($chunk_name_split[0] eq $chunk[0])
			{
				$count_chunk++;
			}
		}
		my @chunk1;
		if($count_chunk == 0)
		{
			$hash_chunk{$index_chunk} = "$chunk[0]"."__1";
			$chunk1[0] = $chunk[0];
		}
		else
		{
			$new_count_chunk = $count_chunk+1;
			$chunk1[0] = "$chunk[0]"."$new_count_chunk";
			$hash_chunk{$index_chunk} = "$chunk[0]"."__$new_count_chunk";
		}
		foreach $m_drel(@final_tree)
		{
			my $string_child = get_field($m_drel, 4, $input);
			my $string_fs_child = read_FS($string_child, $input);

			my @old_drel = get_values("drel", $string_fs_child, $input);
			my @old_dmrel = get_values("dmrel", $string_fs_child, $input);
			my @old_reftype = get_values("reftype", $string_fs_child, $input);
			my @old_coref = get_values("coref", $string_fs_child, $input);
			#my @old_attr = get_attributes($string_fs_child, $input);

			if($old_drel[0]=~/\'/ or $old_drel[0]=~/\"/)
			{
				$old_drel[0]=~s/\'//g;
				$old_drel[0]=~s/\"//g;
			}

			if($old_dmrel[0]=~/\'/ or $old_dmrel[0]=~/\"/)
			{
				$old_dmrel[0]=~s/\'//g;
				$old_dmrel[0]=~s/\"//g;
			}

			if($old_reftype[0]=~/\'/ or $old_reftype[0]=~/\"/)
			{
				$old_reftype[0]=~s/\'//g;
				$old_reftype[0]=~s/\"//g;
			}

			if($old_coref[0]=~/\'/ or $old_coref[0]=~/\"/)
			{
				$old_coref[0]=~s/\'//g;
				$old_coref[0]=~s/\"//g;
			}

			my @old_drel_name = split(/:/, $old_drel[0]);
			my @old_dmrel_name = split(/:/, $old_dmrel[0]);
			my @old_reftype_name = split(/:/, $old_reftype[0]);
			my @old_coref_name = split(/:/, $old_coref[0]);

			if(($old_drel_name[1] eq $old_value_name[0]) && ($old_drel_name[1] ne ""))
			{
				my @new_drel;
				$new_drel[0] = "$old_drel_name[0]:$chunk1[0]";

				del_attr_val("drel", $string_fs_child, $input);
#				add_attr_val("drel", \@new_drel, $string_fs_child, $input);
			}

			if(($old_dmrel_name[1] eq $old_value_name[0]) && ($old_dmrel_name[1] ne ""))
			{
				my @new_dmrel;
				$new_dmrel[0] = "$old_dmrel_name[0]:$chunk1[0]";

				del_attr_val("dmrel", $string_fs_child, $input);
#				add_attr_val("dmrel", \@new_dmrel, $string_fs_child, $input);
			}

			if(($old_reftype_name[1] eq $old_value_name[0]) && ($old_reftype_name[1] ne ""))
			{
				my @new_reftype;
				$new_reftype[0] = "$old_reftype_name[0]:$chunk1[0]";

				del_attr_val("reftype", $string_fs_child, $input);
#				add_attr_val("reftype", \@new_reftype, $string_fs_child, $input);
			}

			if(($old_coref_name[0] eq $old_value_name[0]) && ($old_coref_name[0] ne ""))
			{
				my @new_coref;
				$new_coref[0] = $chunk1[0];

				del_attr_val("coref", $string_fs_child, $input);
#				add_attr_val("coref", \@new_coref, $string_fs_child, $input);
			}

#			my $name_attribute_chunk = make_string($string_fs_child, $input);
#			modify_field($m_drel, 4, $name_attribute_chunk, $input);
		}
		
		del_attr_val("name", $string_fs, $input);
#		add_attr_val("name", \@chunk1, $string_fs, $input);

#		my $name_fs_chunk = make_string($string_fs, $input);
#		modify_field($i, 4, $name_fs_chunk, $input);

		my $string1 = get_field($i, 4, $input);
		my $attr = read_FS($string1, $input);
		#my @attribute_array = get_attributes($attr, $input);

		#$count=@attribute_array;
		#print $count, "\n";
	}

	foreach $i(@final_tree)
	{
		$string = get_field($i, 4, $input);
		@leaves = get_children($i, $input);

		foreach $m(@leaves)
		{
			$count=0;
			$index++;
			$string2 = get_field($m, 4, $input);
			$string_fs2 = read_FS($string2, $input);
			my @token = get_field($m, 2, $input);
			for ($ite=1; $ite<$index; $ite++)
			{
				my $actual_name = $hash_index{$ite};
				my @name_split = split(/__/, $actual_name);
				if($name_split[0] eq $token[0])
				{
					$count++;
				}
			}
			if($count == 0)
			{
				my @token1;
				$token1[0] = $token[0];
				del_attr_val("name", $string_fs2, $input);
				add_attr_val("name", \@token1, $string_fs2, $input);
				my $name_fs = make_string($string_fs2, $input);
				modify_field($m, 4, $name_fs,$input);
				$hash_index{$index} = "$token[0]"."__1";
			}
			else
			{
				$new_count = $count+1;
				my @new_token = "$token[0]"."$new_count";
				del_attr_val("name", $string_fs2, $input);
				add_attr_val("name", \@new_token, $string_fs2,$input);
				my $name_fs = make_string($string_fs2,$input);
				modify_field($m, 4, $name_fs, $input);
				$hash_index{$index} = "$token[0]"."__$new_count";
			}

		}
	}
}

sub computehead {
    my ($input, $output) = @_;

    read_story($input);

    $numBody = get_bodycount();
    for(my($bodyNum)=1;$bodyNum<=$numBody;$bodyNum++)
    {

        $body = get_body($bodyNum,$body);

        # Count the number of Paragraphs in the story
        my($numPara) = get_paracount($body);

        #print STDERR "Paras : $numPara\n";

        # Iterate through paragraphs in the story
        for(my($i)=1;$i<=$numPara;$i++)
        {

            my($para);
            # Read Paragraph
            $para = get_para($i);


            # Count the number of sentences in this paragraph
            my($numSent) = get_sentcount($para);
            #       print STDERR "\n $i no.of sent $numSent";

            #print STDERR "Para Number $i, Num Sentences $numSent\n";

            #print $numSent."\n";

            # Iterate through sentences in the paragraph
            for(my($j)=1;$j<=$numSent;$j++)
            {

                #print " ... Processing sent $j\n";

                # Read the sentence which is in SSF format
                my($sent) = get_sent($para,$j);
                #print STDERR "$sent";
                #       print "check--\n";
                #       print_tree($sent);
                # Get the nodes of the sentence (words in our case)


                #Copy NP head
                #       AddID($sent);
                make_chunk_name($sent);
                copy_np_head($sent,$head_home);
                #Copy NP VG head
                copy_vg_head($sent,$head_home);

            }
        }
    }

    if($output eq "")
    {
        printstory();
    }

    if($output ne "")
    {
        printstory_file("$output");
    }
}
1;
