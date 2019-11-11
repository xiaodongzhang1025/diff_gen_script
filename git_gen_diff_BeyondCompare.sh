echo 'Make sure you have already config difftool with beyond compare!!!'
diff_dir_temp="/C/Users/sse/AppData/Local/Temp"
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

function gen_diff() {
  after_diff_dirs=$(ls $diff_dir_temp | grep git-difftool)
  #echo $before_diff_dirs
  #echo $after_diff_dirs
  echo =========================================
  echo "$after_diff_dirs" | while read line
  do
    result=$(echo $before_diff_dirs | grep $line)
    if [ -d $target_diff_dir ]; then
      rm -rf $target_diff_dir
    fi
    if [ -z "$result" ] ; then
      #echo $diff_dir_temp/$line
      echo "Step 1. Gen diff dir $target_diff_dir."
      
      cp -r $diff_dir_temp/$line $target_diff_dir
      git log -n 1 > $target_diff_dir/commit_id.txt
      break
    fi
  done

  if [ ! -d $target_diff_dir ]; then
    echo 'Error, No diff dir find!!!'
    exit 1
  fi
  
  echo "Step 2. Copy untracked files and dirs."
  all_status=$(git status -s)
  echo "$all_status" | while read line
  do
    line_prefix=${line:0:2}
    tmp_name=${line:3}
    if [ "$line_prefix" = "??" ] ; then
      #echo $tmp_name
      if [ -f $tmp_name ]; then
        cp $tmp_name $target_diff_dir/right/$tmp_name
      else
        cp -r $tmp_name $target_diff_dir/right/$tmp_name
      fi
    fi
  done
}

cd $cur_git_path
echo --------------git status -s 
git status -s
#echo --------------git difftool --name-only --no-symlinks HEAD
#git difftool --name-only --no-symlinks HEAD

before_diff_dirs=$(ls $diff_dir_temp | grep git-difftool)
git difftool -d --no-symlinks HEAD &
sleep 1 && gen_diff

echo '-----------------------------------------'
echo ls -l $target_diff_dir
cd $CUR_DIR
ls $target_diff_dir -l
echo '-----------------The End-----------------'

