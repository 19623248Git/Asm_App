document.addEventListener('DOMContentLoaded', () => {
    const galleryContainer = document.getElementById('gallery-container');
    const statusMessage = document.getElementById('status-message');

    // --- Status Message Function ---
    const showStatus = (message, isError = false) => {
        statusMessage.textContent = message;
        statusMessage.className = isError ? 'error' : 'success';
        setTimeout(() => {
            statusMessage.className = '';
            statusMessage.textContent = '';
        }, 5000);
    };

    // --- Gallery Fetch and Display Function ---
    const fetchAndDisplayImages = async () => {
        try {
            const response = await fetch('/gallery'); // Fetch from /gallery
            if (!response.ok) {
                throw new Error(`Network response was not ok (${response.status})`);
            }
            const images = await response.json();
            
            galleryContainer.innerHTML = ''; // Clear previous content
            
            if (images.length === 0) {
                galleryContainer.innerHTML = '<p>No images found in the directory.</p>';
                return;
            }

            images.forEach(imageName => {
                // Create a container for the image and its name
                const itemContainer = document.createElement('div');
                itemContainer.className = 'gallery-item';

                const imgElement = document.createElement('img');
                imgElement.src = `img/${imageName}`;
                imgElement.alt = `Gallery image ${imageName}`;
                imgElement.onerror = () => {
                    imgElement.alt = `Could not load ${imageName}`;
                };

                // Create a paragraph for the filename
                const nameElement = document.createElement('p');
                nameElement.textContent = imageName;

                itemContainer.appendChild(imgElement);
                itemContainer.appendChild(nameElement);
                galleryContainer.appendChild(itemContainer);
            });
        } catch (error) {
            console.error('Error fetching images:', error);
            galleryContainer.innerHTML = '<p>Error loading images. See console for details.</p>';
            showStatus(error.message, true);
        }
    };

    // --- Event Listeners for Forms ---

    // POST Form
    document.getElementById('post-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        const fileInput = document.getElementById('post-file');
        const file = fileInput.files[0];

        if (!file) {
            showStatus('Please select a file to upload.', true);
            return;
        }

        const formData = new FormData();
        formData.append('file', file); 

        try {
            const response = await fetch('/gallery', { // POST to /gallery
                method: 'POST',
                body: formData
            });

            if (response.ok) {
                showStatus(`Successfully uploaded ${file.name}!`, false);
                fileInput.value = ''; 
                fetchAndDisplayImages();
            } else {
                throw new Error(`Server responded with status: ${response.status}`);
            }
        } catch (error) {
            showStatus(`Error uploading file: ${error.message}`, true);
        }
    });

    // PUT Form
    document.getElementById('put-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        const filename = document.getElementById('put-filename').value;
        const fileInput = document.getElementById('put-file');
        const file = fileInput.files[0];

        if (!filename || !file) {
            showStatus('Please provide a filename and select a file.', true);
            return;
        }

        try {
            const response = await fetch(`/gallery/${filename}`, { // PUT to /gallery/filename
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/octet-stream'
                },
                body: file
            });

            if (response.ok) {
                showStatus(`Successfully updated ${filename}!`, false);
                document.getElementById('put-filename').value = '';
                fileInput.value = '';
                fetchAndDisplayImages();
            } else {
                throw new Error(`Server responded with status: ${response.status}`);
            }
        } catch (error) {
            showStatus(`Error updating file: ${error.message}`, true);
        }
    });

    // DELETE Form
    document.getElementById('delete-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        const filename = document.getElementById('delete-filename').value;

        if (!filename) {
            showStatus('Please provide a filename to delete.', true);
            return;
        }

        if (!confirm(`Are you sure you want to delete ${filename}?`)) {
            return;
        }

        try {
            const response = await fetch(`/gallery/${filename}`, { // DELETE to /gallery/filename
                method: 'DELETE'
            });

            if (response.status === 204) {
                showStatus(`Successfully deleted ${filename}.`, false);
                document.getElementById('delete-filename').value = '';
                fetchAndDisplayImages();
            } else {
                throw new Error(`Server responded with status: ${response.status}`);
            }
        } catch (error) {
            showStatus(`Error deleting file: ${error.message}`, true);
        }
    });

    // Initial load of the gallery
    fetchAndDisplayImages();
});
