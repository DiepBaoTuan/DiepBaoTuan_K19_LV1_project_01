#!/bin/bash
#Q1:
touch resultQ1.txt
curl "https://raw.githubusercontent.com/yinghaoz1/tmdb-movie-dataset-analysis/master/tmdb-movies.csv">DB_P1.txt
sed 's/""/##/g' DB_P1.txt>temp_DB_P1.txt
awk -F '"' -v OFS='"' '{for (i=2; i<=NF; i+=2) gsub(/,/, " ", $i)} 1' temp_DB_P1.txt>F_DB_P1.txt
awk -F, '
NR==1 {
  for (i=1; i<=NF; i++) {
    if ($i == "original_title") ot_col = i
    else if ($i == "release_date") rd_col = i
  }
  print "ReleasedDate\tOriginal_title"
  next
}
{
  split($rd_col, d, "/")
  yy = d[3] + 0
  if (yy > 25) {
    yyyy = 1900 + yy
  } else {
    yyyy = 2000 + yy
  }
  # Construct sortable date yyyy-mm-dd
  sortable_date = yyyy "-" d[2] "-" d[1]
  print sortable_date "\t" $ot_col
}
'F_DB_P1.txt | sort -r>resultQ1.txt

#Q2
awk 'BEGIN { FS = "," } NR > 1 && $18 >= 7.5 { print $18, $6 }' F_DB_P1.txt|sort -r>ResultQ2.txt
#Q3
awk -F"," '
BEGIN {
  min_revenue = 999999999999999
  max_revenue = -1
}

NR==1 {
  # tìm giá trị revenue lớn nhất và nhỏ nhất
  for(i=1; i<=NF; i++) {
    if ($i == "original_title") ot_col = i
    else if ($i == "revenue") rev_col = i
  }
  next
}

{
  if ($rev_col ~ /^[0-9]+$/) {
    # Check for highest revenue
    if ($rev_col + 0 > max_revenue) {
      max_revenue = $rev_col
      max_title = $ot_col
    }

    # Check for lowest revenue (greater than 0)
    if ($rev_col + 0 < min_revenue && $rev_col + 0 > 0) {
      min_revenue = $rev_col
      min_title = $ot_col
    }
  }
}

END {
  print "Movie with the Highest Revenue:"
  print "Title: " max_title
  print "Revenue: " max_revenue
  print ""
  print "Movie with the Lowest Revenue (greater than 0):"
  print "Title: " min_title
  print "Revenue: " min_revenue
}' F_DB_P1.txt

#Q4
awk -F"," '
BEGIN {
  total_revenue = 0
}

NR==1 {
  for(i=1; i<=NF; i++) {
    if ($i == "original_title") ot_col = i
    else if ($i == "revenue") rev_col = i
  }
  next
}

{
  if (rev_col && $rev_col ~ /^[0-9]+$/) {
    total_revenue += $rev_col
  }
}

END {
  #in kết quả
  print "Total revenue: " total_revenue
}' F_DB_P1.txt

#Q5
awk -F',' '{
  if (NR==1) {
    for(i=1; i<=NF; i++) {
      if ($i == "original_title") ot_col = i
      else if ($i == "revenue") rev_col = i
    }
    
    print "Orignial_name\tRevenue"
    next
  }


  if (ot_col && rev_col) {
    # Print the values of the original_title and revenue columns
    print $ot_col"\t"$rev_col
  }
}' temp_DB_P1.txt | sort -k2nr | head -n10

#Q6
#Most appearance director
awk -F',' '
NR==1 {
    for(i=1; i<=NF; i++) {
        if ($i == "director") {
            dir_col = i
            break
        }
    }
    next
}
{
    
    if (dir_col && $dir_col != "") {
        split($dir_col, directors, "|")
        for (j in directors) {
            # Increment the count for each director in an associative array
            count[directors[j]]++
        }
    }
}
END {
    
    for (director in count) {
        print count[director], director
    }
}' F_DB_P1.txt | sort -rn| head -n1

#Most appearance Actor
awk -F',' '
NR==1 {
    for(i=1; i<=NF; i++) {
        if ($i == "cast") {
            cast_col = i
            break
        }
    }
    next
}
{
    if (cast_col && $cast_col != "" && $cast_col!="None@") {
        split($cast_col,casts, "|")
        for (j in casts) {
            # Increment the count for each director in an associative array
            count[casts[j]]++
        }
    }
}
END {
    for (cast in count) {
        print count[cast], cast
    }
}' F_DB_P1.txt | sort -rn | head -n1

#Q7
awk -F',' '
NR==1 {
    for(i=1; i<=NF; i++) {
        if ($i == "genres") {
            dir_col = i
            break
        }
    }
    next
}
{
    if (dir_col && $dir_col != "") {
        split($dir_col, genres, "|")
        for (j in genres) {
            count[genres[j]]++
        }
    }
}
END {
    # Print the results in a formatted way
    for (genre in count) {
        print count[genre], genre
    }
}' F_DB_P1.txt | sort -rn |head -n20
