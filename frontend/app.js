const projectForm = document.querySelector('#project-form');
const projectError = document.querySelector('#project-error');
const saveStatus = document.querySelector('#save-status');
const saveStatusMessage = document.querySelector('#save-status-message');
const calendarGrid = document.querySelector('#calendar-grid');
const startWeekInput = document.querySelector('#start-week');
const projectDialog = document.querySelector('#project-dialog');
const createProjectButton = document.querySelector('#create-project');
const closeProjectDialogButton = document.querySelector('#close-project-dialog');
const periodLabel = document.querySelector('#period-label');
const weekCount = document.querySelector('#week-count');
const declaredDays = document.querySelector('#declared-days');
const activeProjects = document.querySelector('#active-projects');
const missingDeclarations = document.querySelector('#missing-declarations');
const missingWindow = document.querySelector('#missing-window');
const declaredPeriod = document.querySelector('#declared-period');

let lastProjectTrigger = null;

const formatBody = (formData) => new URLSearchParams(formData).toString();
const escapeHtml = (value) => String(value).replace(/[&<>'"]/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' })[character]);
const formatDays = (value) => Number(value || 0).toLocaleString(undefined, { maximumFractionDigits: 2 });

const showStatus = (message = '', type = 'blank') => {
  saveStatus.dataset.state = type;
  saveStatus.replaceChildren();
  if (type !== 'blank') {
    const icon = document.createElement('i');
    icon.dataset.lucide = type === 'saved' ? 'circle-check' : type === 'saving' ? 'loader-circle' : 'circle-alert';
    icon.setAttribute('aria-hidden', 'true');
    saveStatus.append(icon);
  }
  const statusMessage = document.createElement('span');
  statusMessage.id = saveStatusMessage.id;
  statusMessage.textContent = message;
  saveStatus.append(statusMessage);
  renderIcons();
};
const api = async (url, options = {}) => {
  const response = await fetch(url, options);
  const text = await response.text();
  const jsonStart = text.indexOf('{');
  if (!response.ok) throw new Error(`Request failed (${response.status})`);
  return JSON.parse(jsonStart >= 0 ? text.slice(jsonStart) : text);
};

const renderSummary = (summary = {}) => {
  declaredDays.textContent = formatDays(summary.declared_days);
  activeProjects.textContent = formatDays(summary.active_projects);
  missingDeclarations.textContent = formatDays(summary.missing_declarations);
  missingWindow.textContent = summary.missing_window_start ? `${summary.missing_window_start} to ${summary.missing_window_end}` : '-';
  declaredPeriod.textContent = 'Selected period';
};

const renderIcons = () => window.lucide?.createIcons({ attrs: { 'stroke-width': 2 } });
const renderCalendar = (data) => {
  const weeks = data.weeks || [];
  periodLabel.textContent = weeks.length ? `${weeks[0].week_start} to ${weeks.at(-1).week_end}` : 'No period selected';
  weekCount.textContent = `${weeks.length} week${weeks.length === 1 ? '' : 's'}`;
  renderSummary(data.summary);
  if (!data.rows?.length) {
    calendarGrid.innerHTML = '<p class="blank-note">No projects yet. Create a project to begin recording weekly time.</p>';
    return;
  }
  const weekHeaders = weeks.map((week) => `<th class="${week.is_current_week ? 'week-current' : ''}" scope="col"><span class="week-number">Week ${escapeHtml(week.iso_week_number)}</span><span class="week-date">${escapeHtml(week.week_start)}</span></th>`).join('');
  const rows = data.rows.map((row) => {
    const cells = row.cells.map((cell, index) => {
      const isBlank = cell.display_value === '' || cell.display_value === 0;
      const currentWeekClass = weeks[index]?.is_current_week ? ' week-current' : '';
      return `<td class="cell-${cell.status}${currentWeekClass}" data-project-code="${escapeHtml(row.project.project_code)}" data-week-start="${escapeHtml(cell.week_start)}" data-value="${escapeHtml(cell.display_value)}"><button class="day-value" type="button" aria-label="Edit ${escapeHtml(row.project.project_code)} for week ${escapeHtml(cell.week_start)}">${isBlank ? '' : formatDays(cell.display_value)}</button></td>`;
    }).join('');
    return `<tr><th scope="row" class="project-cell">${escapeHtml(row.project.client_name)} : <strong>${escapeHtml(row.project.project_name)}</strong><br><span class="project-code">${escapeHtml(row.project.project_code)}</span></th>${cells}<td class="total-cell">${formatDays(row.lifetime_total_days)}</td></tr>`;
  }).join('');
  const periodCells = weeks.map((week) => `<td class="period-total-${escapeHtml(week.period_total_status)}${week.is_current_week ? ' week-current' : ''}">${formatDays(week.period_total_days)}</td>`).join('');
  calendarGrid.innerHTML = `<table class="calendar-table"><thead><tr><th class="project-header" scope="col">Project</th>${weekHeaders}<th scope="col">Total</th></tr></thead><tbody>${rows}<tr class="period-total"><th scope="row">Period total</th>${periodCells}<td>${formatDays(data.period_total_days)}</td></tr></tbody></table>`;
  renderIcons();
};

const loadCalendar = async () => {
  const query = new URLSearchParams({ week_count: '12' });
  if (startWeekInput.value) query.set('start_week', startWeekInput.value);
  try {
    const result = await api(`/cgi-bin/calendar?${query}`);
    if (!result.ok) throw new Error(result.error.message);
    renderCalendar(result.data);
  } catch (error) {
    calendarGrid.innerHTML = `<p class="blank-note">${escapeHtml(error.message)}</p>`;
    showStatus('Calendar could not be loaded', 'failed');
  }
};

createProjectButton.addEventListener('click', () => {
  lastProjectTrigger = createProjectButton;
  projectError.textContent = '';
  projectDialog.showModal();
  projectForm.elements.client_name.focus();
});
closeProjectDialogButton.addEventListener('click', () => projectDialog.close());
projectDialog.addEventListener('close', () => lastProjectTrigger?.focus());

projectForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  projectError.textContent = '';
  showStatus('Saving project...', 'saving');
  try {
    const result = await api('/cgi-bin/projects', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: formatBody(new FormData(projectForm)) });
    if (!result.ok) {
      projectError.textContent = result.error.message;
      showStatus('Project not saved', 'invalid');
      return;
    }
    projectForm.reset();
    projectDialog.close();
    showStatus('Project saved', 'saved');
    await loadCalendar();
  } catch (error) {
    projectError.textContent = error.message;
    showStatus('Project not saved', 'failed');
  }
});

calendarGrid.addEventListener('click', (event) => {
  const button = event.target.closest('.day-value');
  if (!button) return;
  const cell = button.closest('td');
  const input = document.createElement('input');
  input.className = 'day-input';
  input.value = cell.dataset.value;
  input.inputMode = 'decimal';
  input.setAttribute('aria-label', button.getAttribute('aria-label'));
  button.replaceWith(input);
  input.focus();
  input.select();
});
calendarGrid.addEventListener('input', (event) => {
  if (!event.target.matches('.day-input')) return;
  event.target.closest('td').className = 'cell-unsaved';
  showStatus('Unsaved entry', 'unsaved');
});
calendarGrid.addEventListener('change', async (event) => {
  if (!event.target.matches('.day-input')) return;
  const input = event.target;
  const cell = input.closest('td');
  cell.className = 'cell-saving';
  showStatus('Saving entry...', 'saving');
  try {
    const result = await api('/cgi-bin/timesheet', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: new URLSearchParams({ project_code: cell.dataset.projectCode, week_start: cell.dataset.weekStart, days: input.value }).toString() });
    if (!result.ok) {
      cell.className = 'cell-invalid';
      showStatus(result.error.message, 'invalid');
      return;
    }
    input.value = result.data.entry.days;
    cell.className = 'cell-saved';
    showStatus('Entry saved', 'saved');
    await loadCalendar();
  } catch (error) {
    cell.className = 'cell-failed';
    showStatus(error.message, 'failed');
  }
});

startWeekInput.addEventListener('change', loadCalendar);
renderIcons();
loadCalendar();