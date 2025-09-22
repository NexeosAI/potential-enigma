const brandConfigs = {
  studentlyai: {
    name: 'StudentlyAI',
    tagline: 'Local-first assistant for independent learners.',
    accent: '#F97316',
    sidebarGradient: 'linear-gradient(180deg, #1f2937 0%, #111827 100%)',
    spelling: 'british',
    marketLabel: 'Marketplace',
  },
  studentsai_uk: {
    name: 'StudentsAI UK',
    tagline: 'Academic toolkit for UK colleges and universities.',
    accent: '#1E3A8A',
    sidebarGradient: 'linear-gradient(180deg, #111c44 0%, #0b1531 100%)',
    spelling: 'british',
    marketLabel: 'Marketplace',
  },
  studentsai_us: {
    name: 'StudentsAI US',
    tagline: 'Guided study companion for AP, IB, and college prep.',
    accent: '#0369A1',
    sidebarGradient: 'linear-gradient(180deg, #0c1e35 0%, #082032 100%)',
    spelling: 'american',
    marketLabel: 'Marketplace',
  },
};

const moduleData = (brand) => ({
  workspace: {
    title: 'Workspace Overview',
    description:
      'Organise courses, notes, and reading packs into visual folders with drag-and-drop support.',
    cards: [
      {
        title: 'Course Planner',
        body:
          'Create course folders, nest units, and keep seminar notes alongside uploaded reading packs.',
        tags: ['Folders', 'Timetable sync', 'Tagging'],
      },
      {
        title: 'File Ingestion',
        body: 'Drop in PDF, EPUB, DOCX, and TXT files. The desktop app prepares them for offline study.',
        tags: ['PDF', 'EPUB', 'DOCX', 'TXT'],
      },
      {
        title: 'Collaboration Preview',
        body: 'Invite your peers via secure share links. Joint highlighting and annotations arrive post-beta.',
        tags: ['Shared notes', 'Highlights'],
      },
    ],
  },
  models: {
    title: 'Model Manager',
    description:
      'Install GGUF packages or connect to cloud providers. The assistant picks the best option per task.',
    cards: [
      {
        title: 'Local Models',
        body:
          'Optimised builds of Qwen3-0.6B, Gemma3-270M, and Gemma3-1B are tuned for laptops with 8GB+ RAM.',
        tags: ['GGUF', 'MLC', 'Offline'],
      },
      {
        title: 'Cloud Connectors',
        body:
          'Route to OpenRouter, OpenAI, Anthropic, or Groq. Bring your own key and pick a default model.',
        tags: ['API keys', 'Provider routing'],
      },
      {
        title: 'Smart Recommendations',
        body:
          'Storage-aware prompts nudge you toward models that fit your device capacity and study goals.',
        tags: ['Recommendations', 'Device checks'],
      },
    ],
  },
  rag: {
    title: 'Knowledge & Citations',
    description:
      'Turn your workspace into a searchable knowledge base with local embeddings and citation support.',
    cards: [
      {
        title: 'Embedding Pipeline',
        body:
          'BGE-small and e5-small GGUF embeddings run locally. LanceDB keeps vectors synced with your notes.',
        tags: ['Embeddings', 'Vector store'],
      },
      {
        title: 'Retriever',
        body:
          'Hybrid semantic + keyword retrieval means you can surface quotes instantly while drafting essays.',
        tags: ['Hybrid search', 'Metadata filters'],
      },
      {
        title: 'Citation Service',
        body:
          'Export Harvard or APA formatted references with one click, ready to drop into submissions.',
        tags: ['APA', 'Harvard', 'Referencing'],
      },
    ],
  },
  sync: {
    title: 'Sync & Devices',
    description:
      'Pair laptops, tablets, and mobiles securely. Start P2P sync in class, add cloud drives for backup.',
    cards: [
      {
        title: 'P2P via QR',
        body:
          'Generate a QR code to pair another device instantly over WebRTC. Ideal for offline campuses.',
        tags: ['WebRTC', 'Offline'],
      },
      {
        title: 'Cloud Drives',
        body:
          'Optional Google Drive, iCloud Drive, and Dropbox connectors let you back up notes to the cloud.',
        tags: ['Google Drive', 'iCloud', 'Dropbox'],
      },
      {
        title: 'Institutional Access',
        body:
          'Future adapters connect to university-managed storage so cohorts can share study packs safely.',
        tags: ['Universities', 'Admin controls'],
      },
    ],
  },
  marketplace: {
    title: brand.marketLabel,
    description:
      'Discover optional add-ons for research, career planning, and classroom workflows. Buy once, own forever.',
    cards: [
      {
        title: 'Research Pack',
        body:
          'Batch summarise journal PDFs, auto-extract citations, and build reading digests for seminars.',
        tags: ['Summaries', 'Citation extraction'],
      },
      {
        title: 'Classroom Pack',
        body: 'Plan lessons, auto-generate worksheets, and share resources with fellow educators.',
        tags: ['Lesson plans', 'Worksheets'],
      },
      {
        title: 'Careers Pack',
        body:
          'AI support for CV reviews, interview prep, and apprenticeship discovery tailored to your brand.',
        tags: ['CV review', 'Interview prep'],
      },
    ],
  },
  settings: {
    title: 'Settings & Accounts',
    description:
      'Manage your licence, view device activations, and fine-tune privacy controls.',
    cards: [
      {
        title: 'Licence Overview',
        body:
          'See your current tier, remaining device activations, and renewal options once the beta ends.',
        tags: ['Licence', 'Tier status'],
      },
      {
        title: 'Privacy Controls',
        body:
          'Toggle telemetry, offline mode, and parental controls. Everything defaults to privacy-first.',
        tags: ['Telemetry', 'Parental controls'],
      },
      {
        title: 'Support',
        body:
          'Contact the McCaigs support desk or browse the knowledge base for quick fixes.',
        tags: ['Support', 'Knowledge base'],
      },
    ],
  },
});

const brandKey = window.mcCaigs?.brand ?? 'studentlyai';
const brand = brandConfigs[brandKey] ?? brandConfigs.studentlyai;

function adaptCopy(text) {
  if (brand.spelling === 'american') {
    return text
      .replaceAll('Organise', 'Organize')
      .replaceAll('organise', 'organize')
      .replaceAll('Licence', 'License')
      .replaceAll('licence', 'license')
      .replaceAll('favourite', 'favorite');
  }
  return text;
}

function updateBrandUi() {
  document.documentElement.style.setProperty('--accent', brand.accent);
  const sidebar = document.querySelector('.sidebar');
  if (sidebar) {
    sidebar.style.background = brand.sidebarGradient;
  }

  const activeButtons = document.querySelectorAll('.nav-item.active');
  activeButtons.forEach((button) => {
    button.style.background = 'rgba(248, 250, 252, 0.95)';
    button.style.color = '#0f172a';
  });

  const brandName = document.getElementById('brand-name');
  const brandTagline = document.getElementById('brand-tagline');
  const brandSpelling = document.getElementById('brand-spelling');

  if (brandName) brandName.textContent = brand.name;
  if (brandTagline) brandTagline.textContent = brand.tagline;
  if (brandSpelling) {
    brandSpelling.textContent =
      brand.spelling === 'american'
        ? 'License-friendly language for US students.'
        : 'Licence-friendly language for UK and international cohorts.';
  }
}

function renderModule(key) {
  const data = moduleData(brand)[key];
  if (!data) {
    return;
  }

  const title = document.getElementById('module-title');
  const description = document.getElementById('module-description');
  const container = document.getElementById('module-content');

  if (title) title.textContent = adaptCopy(data.title);
  if (description) description.textContent = adaptCopy(data.description);

  if (container) {
    container.innerHTML = '';
    data.cards.forEach((card) => {
      const element = document.createElement('article');
      element.className = 'card';

      const heading = document.createElement('h3');
      heading.textContent = adaptCopy(card.title);
      element.appendChild(heading);

      const body = document.createElement('p');
      body.textContent = adaptCopy(card.body);
      element.appendChild(body);

      if (card.tags?.length) {
        const tagList = document.createElement('div');
        tagList.className = 'tag-list';
        card.tags.forEach((tag) => {
          const tagEl = document.createElement('span');
          tagEl.className = 'tag';
          tagEl.textContent = adaptCopy(tag);
          tagList.appendChild(tagEl);
        });
        element.appendChild(tagList);
      }

      container.appendChild(element);
    });
  }
}

function bindNavigation() {
  const buttons = document.querySelectorAll('.nav-item');
  buttons.forEach((button) => {
    button.addEventListener('click', () => {
      buttons.forEach((btn) => btn.classList.remove('active'));
      button.classList.add('active');
      const moduleKey = button.dataset.module;
      renderModule(moduleKey);
    });
  });
}

updateBrandUi();
bindNavigation();
renderModule('workspace');
