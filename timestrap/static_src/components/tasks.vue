<template>
<div class="container">
    <div v-if="this.$perms.add_task" class="row py-2 mb-4 bg-faded rounded">
        <div class="col-12">
            <button name="task-add"
                    type="button"
                    class="btn btn-primary btn-sm"
                    @click="toggleModal"
                    v-if="this.$perms.add_task">
                <i class="fa fa-plus mr-1" aria-hidden="true"></i>
                New Task
            </button>
        </div>
    </div>

    <task-modal id="task-modal"
                v-if="modal_config.show && (this.$perms.add_task || this.$perms.change_task)"
                @updateTask="updateTask"
                @close="toggleModal"
                v-bind:config="modal_config"></task-modal>

    <div v-if="this.$perms.view_task" id="task-rows" class="rounded">
        <task v-for="(task, index) in tasks"
              @removeTask="removeTask"
              v-bind:task="task"
              v-bind:index="index"
              v-bind:key="task.id"
              v-bind:toggleEditModal="toggleModal"></task>
    </div>
</div>
</template>


<script>
const Task = require('./task.vue');
const TaskModal = require('./task-modal.vue');

export default {
    data() {
        return {
            tasks: null,
            modal_config: { index: null, task: null, show: false }
        };
    },
    methods: {
        getTasks(url) {
            url = (typeof url !== 'undefined') ? url : timestrapConfig.API_URLS.TASKS;

            this.$quickFetch(url).then(data => {
                this.tasks = data;
            }).catch(error => console.log(error));
        },
        updateTask(task, index) {
            if (task && (index || index === 0)) {
                this.tasks[index] = task;
            }
            else {
                this.tasks.unshift(task);
            }
            this.modal_config.index = null;
            this.modal_config.task = null;
        },
        removeTask(index) {
            this.tasks.splice(1, index);
        },
        toggleModal(task, index) {
            if (task && (index || index === 0)) {
                this.modal_config.task = task;
                this.modal_config.index = index;
            }
            else {
                this.modal_config.task = null;
                this.modal_config.index = null;
            }
            this.modal_config.show = !this.modal_config.show;
        }
    },
    mounted() {
        return this.getTasks();
    },
    components: {
        Task,
        TaskModal
    }
};
</script>
