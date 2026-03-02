lib git/archive.sh

_worker_sandbox_init() {
    _git_archive_filter $agent_job_git_repository $agent_job_git_branch $agent_job_work_element_path $agent_job_work_path

    cd $agent_job_work_path
    git init
    git add .
    git commit -am 'init work'

    agent_work_initial_commit=$(git rev-parse --short=8 HEAD --)
}

_worker_sandbox_run() {
}

_worker_sandbox_patch() {
    git commit -am 'final work'
    
    git diff $agent_work_initial_commit > patch

}
