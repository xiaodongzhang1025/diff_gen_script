
CUR_DIR=$(pwd)
if [ ! -z $1 ] ; then
  cd $1
fi

cur_git_path=$(git rev-parse --show-toplevel)
cur_git_dir=${cur_git_path##*/}
target_diff_dir=~/$cur_git_dir-Diff
#echo $cur_git_path
#echo $cur_git_dir
#echo $target_diff_dir
if [ -z "$cur_git_path" ] ;then
  echo 'Enter a git repository to run this script Or run this script with git repository path as parameter!!!'
  exit 1
fi

if [ -d $target_diff_dir ]; then
  rm -rf $target_diff_dir
fi
mkdir $target_diff_dir
mkdir $target_diff_dir/mod
mkdir $target_diff_dir/org

cd $cur_git_path
all_status=$(git status -s)
echo --------------git status -s 
git status -s
echo "$all_status" | while read line
do
  line_prefix=$(echo $line|awk '{print $1}')
  tmp_name=$(echo $line|awk '{print $2}')
  echo -n "."
  #echo =============================
  #echo $line
  #echo $line_prefix
  #echo $tmp_name
  if [ "$line_prefix" = "??" ] || [ "$line_prefix" = "A" ] ; then
    #echo "Add   ----------$tmp_name"
    newpath=$target_diff_dir/mod/$tmp_name
    newdir=${newpath%/*}
    if [ ! -d $newdir ] ; then
      mkdir -p $newdir
    fi
    
    if [ -f $tmp_name ]; then
      cp -p  $tmp_name $target_diff_dir/mod/$tmp_name
    else
      cp -p  -r --parents $tmp_name $target_diff_dir/mod/
    fi
  elif [ "$line_prefix" = "D" ] ; then
    #echo "Delete----------$tmp_name"
    git checkout -- $tmp_name
    
    newpath=$target_diff_dir/org/$tmp_name
    newdir=${newpath%/*}
    if [ ! -d $newdir ] ; then
      mkdir -p $newdir
    fi
    
    cp -p  $tmp_name $target_diff_dir/org/$tmp_name
    rm -f $tmp_name
  elif [ "$line_prefix" = "M" ] ; then
    #echo "Modify----------$tmp_name"
    newpath=$target_diff_dir/mod/$tmp_name
    newdir=${newpath%/*}
    if [ ! -d $newdir ] ; then
      mkdir -p $newdir
    fi
    
    cp -p  $tmp_name $target_diff_dir/mod/$tmp_name
    
    git checkout -- $tmp_name
    
    newpath=$target_diff_dir/org/$tmp_name
    newdir=${newpath%/*}
    if [ ! -d $newdir ] ; then
      mkdir -p $newdir
    fi
    
    cp -p  $tmp_name $target_diff_dir/org/$tmp_name
    cp -p  $target_diff_dir/mod/$tmp_name $tmp_name
  fi
done
git log -n 1 > $target_diff_dir/commit_id.txt
echo '-----------------------------------------'
echo ls -l $target_diff_dir
cd $CUR_DIR
ls $target_diff_dir -l
echo '-----------------The End-----------------'

