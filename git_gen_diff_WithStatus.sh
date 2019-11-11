
CUR_DIR=$(pwd)
if [ ! -z $1 ] ; then
  cd $1
fi

cur_git_path=$(git rev-parse --show-toplevel)
cur_git_dir=${cur_git_path##*/}
target_git_diff_dir=~/Git-Diff/$cur_git_dir
if [ ! -z $2 ] ; then
  target_git_diff_dir=$2
fi
#echo $cur_git_path
#echo $cur_git_dir
#echo $target_git_diff_dir
if [ -z "$cur_git_path" ] ;then
  echo 'Enter a git repository to run this script Or run this script with git repository path as parameter!!!'
  exit 1
fi

if [ -d $target_git_diff_dir ]; then
  rm -rf $target_git_diff_dir
fi
mkdir -p $target_git_diff_dir
mkdir -p $target_git_diff_dir/mod
mkdir -p $target_git_diff_dir/org

cd $cur_git_path
all_status=$(git status -s)
echo --------------git status -s 
git status -s
echo "$all_status" | while read line
do
  #echo =============================
  #echo "$line"
  if [ -z "$line" ] ; then
    break
  fi
  line_prefix=$(echo "$line" | awk '{print $1}')
  tmp_name=$(echo "$line" | awk '{print $2}')
  echo -n "."
  
  #echo $line_prefix
  #echo $tmp_name
  if [ "$line_prefix" = "D" ] ; then
    #echo "Delete----------$tmp_name"
    git checkout -- $tmp_name
    
    newpath=$target_git_diff_dir/org/$tmp_name
    newdir=${newpath%/*}
    if [ ! -d $newdir ] ; then
      mkdir -p $newdir
    fi
    
    cp -p  $tmp_name $target_git_diff_dir/org/$tmp_name
    rm -f $tmp_name
  elif [ "$line_prefix" = "M" ] ; then
    #echo "Modify----------$tmp_name"
    newpath=$target_git_diff_dir/mod/$tmp_name
    newdir=${newpath%/*}
    if [ ! -d $newdir ] ; then
      mkdir -p $newdir
    fi
    
    cp -p  $tmp_name $target_git_diff_dir/mod/$tmp_name
    
    git checkout -- $tmp_name
    
    newpath=$target_git_diff_dir/org/$tmp_name
    newdir=${newpath%/*}
    if [ ! -d $newdir ] ; then
      mkdir -p $newdir
    fi
    
    cp -p  $tmp_name $target_git_diff_dir/org/$tmp_name
    cp -p  $target_git_diff_dir/mod/$tmp_name $tmp_name
  else
    #echo "Add   ----------$tmp_name"
    newpath=$target_git_diff_dir/mod/$tmp_name
    newdir=${newpath%/*}
    if [ ! -d $newdir ] ; then
      mkdir -p $newdir
    fi
    
    if [ -f $tmp_name ]; then
      #echo cp -p  $tmp_name $target_git_diff_dir/mod/$tmp_name
      cp -p  $tmp_name $target_git_diff_dir/mod/$tmp_name
    else
      #echo cp -p  -r --parents $tmp_name $target_git_diff_dir/mod/
      cp -p -r $tmp_name/* $target_git_diff_dir/mod/$tmp_name
    fi
  fi
done
git log -n 1 > $target_git_diff_dir/commit_id.txt
echo '-----------------------------------------'
echo $target_git_diff_dir
#echo ls -l $target_git_diff_dir
#ls $target_git_diff_dir -l

echo '-----------------The End-----------------'
cd $CUR_DIR
