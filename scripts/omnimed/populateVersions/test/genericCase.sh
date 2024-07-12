#cd $HOME/git/Omnimed-solutions

#git checkout -f upstream/feature-cp-22535-FixCssPit

WORK_DIR="$HOME/.config/scripts/omnimed/populateVersions"
$WORK_DIR/version.sh && $WORK_DIR/rebuild.sh
