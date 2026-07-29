const projectForm = document.querySelector('#project-form');
const projectError = document.querySelector('#project-error');
const saveStatus = document.querySelector('#save-status');
const calendarGrid = document.querySelector('#calendar-grid');
const startWeekInput = document.querySelector('#start-week');

const formatBody = (formData) => new URLSearchParams(formData).toString();

const showStatus = (message, type = 'saved') => {
  saveStatus.textContent = message;
  saveStatus.dataset.state = type;
};

const api = async (url, options = {}) => {
  const response = await fetch(url, options);
  const text = await response.text();
  const jsonStart = text.indexOf('{');
  return JSON.parse(jsonStart >= 0 ? text.slice(jsonStart) : text);
};

const mondayForToday = () => {
  const date = new Date();
  const day = date.getDay() || 7;
  date.setDate(date.getDate() - day + 1);
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const monthDay = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${monthDay}`;
};

const loadCalendar = async () => {
  const startWeek = startWeekInput.value || mondayForToday();
  startWeekInput.value = startWeek;
  try {
    const result = await api(`/cgi-bin/calendar?start_week=${encodeURIComponent(startWeek)}&week_count=12`);
    if (!result.ok) throw new Error(result.error.message);
    renderCalendar(result.data);
  } catch (error) {
    calendarGrid.innerHTML = `<p class="blank-note">${error.message}</p>`;
  }
};

const renderCalendar = (data) => {
  if (!data.rows || data.rows.length === 0) {
    calendarGrid.innerHTML = '<p class="blank-note">No projects yet.</p>';
    return;
  }
  const weekHeaders = data.weeks.map((week) => `<th>${week.label}</th>`).join('');
  const rows = data.rows.map((row) => {
    const cells = row.cells.map((cell) => `
      <td class="cell-${cell.status}">
        <input class="day-input" data-project-code="${row.project.project_code}" data-week-start="${cell.week_start}" value="${cell.display_value}" inputmode="decimal" aria-label="${row.project.project_code} ${cell.week_start}">
      </td>`).join('');
    return `<tr><th class="project-cell">${row.project.client_name}<br>${row.project.project_name}<br><small>${row.project.project_code}</small></th>${cells}</tr>`;
  }).join('');
  calendarGrid.innerHTML = `<table class="calendar-table"><thead><tr><th>Project</th>${weekHeaders}</tr></thead><tbody>${rows}</tbody></table>`;
};

projectForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  projectError.textContent = '';
  showStatus('Saving project...');
  const body = formatBody(new FormData(projectForm));
  const result = await api('/cgi-bin/projects', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body,
  });
  if (!result.ok) {
    projectError.textContent = result.error.message;
    showStatus('Project not saved', 'invalid');
    return;
  }
  projectForm.reset();
  showStatus('Project saved');
  await loadCalendar();
});

calendarGrid.addEventListener('change', async (event) => {
  if (!event.target.matches('.day-input')) return;
  const input = event.target;
  input.closest('td').className = 'cell-saved';
  showStatus('Saving entry...');
  const body = new URLSearchParams({
    project_code: input.dataset.projectCode,
    week_start: input.dataset.weekStart,
    days: input.value,
  }).toString();
  try {
    const result = await api('/cgi-bin/timesheet', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body,
    });
    if (!result.ok) {
      input.closest('td').className = 'cell-invalid';
      showStatus(result.error.message, 'invalid');
      return;
    }
    input.value = result.data.entry.days;
    showStatus('Entry saved');
  } catch (error) {
    input.closest('td').className = 'cell-failed';
    showStatus(error.message, 'failed');
  }
});

startWeekInput.addEventListener('change', loadCalendar);
loadCalendar();