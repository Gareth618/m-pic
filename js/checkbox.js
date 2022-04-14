let checked = false;

function toggleChecked(event) {
  const checkbox = document.getElementById('checkbox').classList;
  if (checked) {
    checkbox.remove('fa-square-check');
    checkbox.add('fa-square-xmark');
    checked = false;
  }
  else {
    checkbox.remove('fa-square-xmark');
    checkbox.add('fa-square-check');
    checked = true;
  }
  checkbox.add('fa-shake');
  setTimeout(() => {
    checkbox.remove('fa-shake');
  }, 500);
  if (event != null) {
    event.preventDefault();
  }
}
