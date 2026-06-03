const prisma = require('../config/prisma');

// 1. Mengambil semua daftar pilihan makanan dari database
const getFoodMasterList = async (req, res) => {
  try {
    const foodMaster = await prisma.foodMaster.findMany();
    
    // SEEDING OTOMATIS: Jika database master masih kosong saat pertama kali dicoba, 
    // kita isi data default buat bahan demo biar tidak kosong
    if (foodMaster.length === 0) {
      const dummyMaster = await prisma.foodMaster.createMany({
        data: [
          { title: "Oatmeal + Susu", kcal: 320, tag: "Sehat" },
          { title: "Nasi Goreng Ayam", kcal: 550, tag: "Berat" },
          { title: "Roti Gandum", kcal: 150, tag: "Ringan" },
          { title: "Salad Sayur", kcal: 120, tag: "Sehat" },
          { title: "Ayam Bakar Dada", kcal: 280, tag: "Protein" }
        ]
      });
      const updatedList = await prisma.foodMaster.findMany();
      return res.json(updatedList);
    }

    res.json(foodMaster);
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// 2. Menyimpan makanan yang dipilih/dimakan user hari ini
const addFoodLog = async (req, res) => {
  try {
    const { title, kcal, time, tag } = req.body;
    const log = await prisma.foodLog.create({
      data: {
        title,
        kcal: parseInt(kcal),
        time,
        tag,
        userId: req.user.userId // didapat dari authMiddleware
      }
    });
    res.status(201).json(log);
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// 3. Mengambil riwayat makanan yang sudah dimakan user hari ini
const getFoodLogs = async (req, res) => {
  try {
    const logs = await prisma.foodLog.findMany({
      where: { userId: req.user.userId },
      orderBy: { date: 'desc' }
    });
    res.json(logs);
  } catch (error) {
    console.log(error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = {
  getFoodMasterList,
  addFoodLog,
  getFoodLogs
};