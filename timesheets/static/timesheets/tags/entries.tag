<entries>
    <div class="row py-2 mb-4 bg-faded rounded">
        <div class="col-12">
            <pager update={ getEntries }/>
        </div>
    </div>

    <div class="row py-1 bg-inverse text-white font-weight-bold rounded-top">
        <div class="col-sm-2">
            Date
        </div>
        <div class="col-sm-2">
            Project
        </div>
        <div class="col-sm-4">
            Note
        </div>
        <div class="col-sm-2">
            Duration
        </div>
        <div class="col-sm-2">
        </div>
    </div>

    <form class="row mb-4 py-2 bg-faded rounded-bottom"
          onsubmit={ submitEntry }
          if={ perms && perms.add_entry }>
        <div class="col-sm-2">
            <input type="text"
                   class="form-control form-control-sm date-input"
                   ref="date"
                   placeholder="Date"/>
        </div>
        <div class="col-sm-2">
            <select class="custom-select" ref="project" required>
                <option><!-- For select2 placeholder to work --></option>
                <optgroup each={ c in clients } label={ c }>
                    <option each={ projects }
                            value={ url }
                            if={ c === client_details.name }>
                        { name }
                    </option>
                </optgroup>
            </select>
        </div>
        <div class="col-sm-4">
            <input type="text"
                   class="form-control form-control-sm"
                   ref="note"
                   placeholder="Note"/>
        </div>
        <div class="col-sm-2">
            <input type="text"
                   class="form-control form-control-sm text-right font-weight-bold"
                   onblur={ timeFromInput }
                   ref="duration"
                   required/>
        </div>
        <div class="col-sm-2">
            <button type="submit"
                    class="btn btn-success btn-sm w-100">
                Add
            </button>
        </div>
    </form>

    <div class="mb-4" each={ d in dates }>
        <div class="row inset-row">
            <div class="col-12">
                <h2 class="display-4 text-muted">{ d }</h5>
            </div>
        </div>
        <div class="entry-rows rounded">
            <entry each={ entries }
                   if={ d === date }
                   class="row py-2 bg-faded small"
                   perms={ perms} />
        </div>
    </div>

    <div class="row bg-success text-white py-2 mb-4 rounded">
        <div class="offset-sm-6 col-sm-2 text-right">
            Subtotal<br>
            <strong>Total</strong>
        </div>
        <div class="col-sm-2 text-right">
            { durationToString(subtotalDuration) }<br>
            <strong>{ durationToString(totalDuration) }</strong>
        </div>
    </div>


    <style>
    </style>


    <script>

        timeFromInput(evt) {
          let value = evt.currentTarget.value;
          let hours = 0;
          let minutes = 0;
          if (isNaN(parseInt(value))) return;
          if (value < 10) {
            hours = value;
          } else {
            minutes = value % 60;
            hours  = Math.floor(value/60);
          }
          minutes = ("0" + minutes).substr(-2);
          evt.currentTarget.value = `${hours}:${minutes}`;
        }

        getEntries(url) {
            url = (typeof url !== 'undefined') ? url : entriesApiUrl;

            let entries = quickFetch(url);
            let projects = quickFetch(projectsApiUrl);

            Promise.all([entries, projects]).then(function(e) {
                let dates = [];
                $.each(e[0].results, function(i, entry) {
                    entry.date = moment(entry.date).format('LL');
                    if ($.inArray(entry.date, dates) === -1) {
                        dates.push(entry.date);
                    }
                });

                let clients = [];
                $.each(e[1].results, function(i, project) {
                    if ($.inArray(project.client_details.name, clients) === -1) {
                        clients.push(project.client_details.name);
                    }
                });

                this.update({
                    dates: dates,
                    clients: clients,
                    entries: e[0].results,
                    projects: e[1].results,
                    totalDuration: e[0].total_duration,
                    subtotalDuration: e[0].subtotal_duration,
                    next: e[0].next,
                    previous: e[0].previous
                });

                $('.custom-select').select2({
                    placeholder: 'Project',
                    width: '100%',
                    dropdownAutoWidth: true
                });

                $('.date-input').pickadate({
                    format: 'yyyy-mm-dd',
                    onStart: function() {
                        this.set('select', new Date());
                    }
                });
            }.bind(this));
        }


        submitEntry(e) {
            e.preventDefault();
            let body = {
                user: userApiUrl,
                duration: this.refs.duration.value,
                note: this.refs.note.value,
                project: this.refs.project.value,
                date: this.refs.date.value
            };
            quickFetch(entriesApiUrl, 'post', body).then(function(data) {
                this.refs.duration.value = '';
                this.refs.note.value = '';
                if (data.id) {
                    data.date = moment(data.date).format('LL');
                    this.entries.unshift(data);
                    if ($.inArray(data.date, this.dates) === -1) {
                        this.dates.unshift(data.date);
                    }
                    this.updateTotals(data.duration, 0);
                }
            }.bind(this));
        }


        updateTotals(newDuration, oldDuration) {
            this.totalDuration += newDuration - oldDuration;
            this.subtotalDuration += newDuration - oldDuration;
            this.update();
        }


        getPerms() {
            quickFetch('/api/permissions/').then(function(data) {
                   let perms = Object;
                   $.each(data.results, function(i, perm) {
                        perms[perm.codename] = perm;
                    });
                   this.perms = perms;
                });
        }


        this.on('mount', function() {
            this.getPerms();
            this.getEntries();
        }.bind(this));
    </script>
</entries>
