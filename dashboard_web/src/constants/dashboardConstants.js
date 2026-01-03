import homeImage from '../assets/home.jpeg';
import aromaDiffuserImg from '../assets/Aroma Diffuser.png';
import airConditionerImg from '../assets/Air Conditioner.png';
import smartLampImg from '../assets/Smart Lamp.png';
import smartLamp2Img from '../assets/Smart Lamp 2.png';
import speakerImg from '../assets/Speaker.png';
import humidifierImg from '../assets/Humidifier.png';
import livingroomImg from '../assets/Phòng khách.png';
import bedroomImg from '../assets/Phòng ngủ.png';
import kitchenroomImg from '../assets/Phòng bếp.png';
import bathroomImg from '../assets/Phòng tắm.png';
import ichomeImg from '../assets/ichome.png';
import livingDetailImg from '../assets/living_detail.png';

export const IMAGES = {
    home: homeImage,
    aromaDiffuser: aromaDiffuserImg,
    airConditioner: airConditionerImg,
    smartLamp: smartLampImg,
    smartLamp2: smartLamp2Img,
    speaker: speakerImg,
    humidifier: humidifierImg,
    livingroom: livingroomImg,
    bedroom: bedroomImg,
    kitchenroom: kitchenroomImg,
    bathroom: bathroomImg,
    ichome: ichomeImg,
    livingDetail: livingDetailImg
};

// Helper để map ảnh từ Flutter App (assets/images/...) sang Web Assets
export const resolveDeviceImage = (imagePath) => {
    if (!imagePath) return IMAGES.smartLamp;

    // Nếu là ảnh Web sẵn có (khi chạy local cũ)
    if (Object.values(IMAGES).includes(imagePath)) return imagePath;

    // Map các path từ Flutter
    if (imagePath.includes("Smart_Lamp")) return IMAGES.smartLamp;
    if (imagePath.includes("Speaker")) return IMAGES.speaker;
    if (imagePath.includes("Humidifier")) return IMAGES.humidifier;
    if (imagePath.includes("Air Conditioner")) return IMAGES.airConditioner;
    if (imagePath.includes("Aroma Diffuser")) return IMAGES.aromaDiffuser;
    if (imagePath.includes("Light")) return IMAGES.smartLamp2; // ví dụ
    if (imagePath.includes("Fan")) return IMAGES.airConditioner; // ví dụ

    // Default
    return IMAGES.smartLamp;
};

export const HOUSE_URL = IMAGES.home;
export const ROOM_IMG = IMAGES.livingroom;
export const DEVICE_IMG_BASE = IMAGES.smartLamp;
export const IC_HOME = IMAGES.ichome;

export const ROOM_IMAGES = {
    "Phòng khách": IMAGES.livingroom,
    "Phòng ngủ": IMAGES.bedroom,
    "Nhà bếp": IMAGES.kitchenroom,
    "Phòng tắm": IMAGES.bathroom
};

export const DEVICES = [
    { name: 'Aroma Diffuser', image: IMAGES.aromaDiffuser },
    { name: 'Air Conditioner', image: IMAGES.airConditioner },
    { name: 'Humidifier', image: IMAGES.humidifier },
    { name: 'Speaker', image: IMAGES.speaker },
    { name: 'Smart Lamp', image: IMAGES.smartLamp },
    { name: 'Smart Lamp 2', image: IMAGES.smartLamp2 },
];
