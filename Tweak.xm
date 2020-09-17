#include "substrate.h"
#include <string>
#include <cstdio>
#include <mach-o/dyld.h>
#include <memory>
#include <vector>
#include <stdint.h>

struct TextureUVCoordinateSet;
struct Mob;

struct Item {
	uintptr_t** vtable; // 0
	uint8_t maxStackSize; // 8
	int idk; // 12
	std::string atlas; // 16
	int frameCount; // 40
	bool animated; // 44
	short itemId; // 46
	std::string name; // 48
	std::string idk3; // 72
	bool isMirrored; // 96
	short maxDamage; // 98
	bool isGlint; // 100
	bool renderAsTool; // 101
	bool stackedByData; // 102
	uint8_t properties; // 103
	int maxUseDuration; // 104
	bool explodeable; // 108
	bool shouldDespawn; // 109
	bool idk4; // 110
	uint8_t useAnimation; // 111
	int creativeCategory; // 112
	float idk5; // 116
	float idk6; // 120
	char buffer[12]; // 124
	TextureUVCoordinateSet* icon; // 136
	char filler[100];
};

struct Block
{
	void** vtable;
	int blockId;
};

struct ItemInstance {
	uint8_t count;
	uint16_t aux;
	uintptr_t* tag;
	Item* item;
	Block* block;
	int idk[3];
};

struct BlockID {
	unsigned char value;

	BlockID() { this->value = 1; }
	BlockID(unsigned char val) { this->value = val; }
	BlockID(BlockID const& other) { this->value = other.value; }
	bool operator==(char v) { return this->value == v; }
	bool operator==(int v) { return this->value == v; }
	bool operator==(BlockID v) { return this->value == v.value; }
	operator unsigned char() { return this->value; }
	BlockID& operator=(const unsigned char& v) {
		this->value = v;
		return *this;
	}
};

static Block** Block$mBlocks;

static Item** Item$mItems;
static Item*(*Item$Item)(Item*, const std::string&, short);
static Item*(*Item$setIcon)(Item*, const std::string&, int);
static Item*(*Item$setHandEquipped)(Item*);

static void(*Item$addCreativeItem)(const ItemInstance&);

static ItemInstance*(*ItemInstance$ItemInstance)(ItemInstance*, int, int, int);
static void(*ItemInstance$hurtAndBreak)(ItemInstance*, int, Mob*);
static int(*ItemInstance$getId)(ItemInstance*);

int emerald_sword = 480;

Item* emerald_sword_;

static void (*_Item$initCreativeItems)();
static void Item$initCreativeItems() {
	_Item$initCreativeItems();

	//EmeraldSword

	ItemInstance sword_inst;
	ItemInstance$ItemInstance(&sword_inst, emerald_sword, 1, 0);
	Item$addCreativeItem(sword_inst);
}

//Ms.Marina Terry taught me this.
//MSHookFunction only allows you to hook functions longer than 12 bytes, but this prevents you from doing so.
//vtable is seriously the best.

size_t __vtable_get_size(uintptr_t** vt) {
	size_t size = 0;
	while(*vt != nullptr) {
		vt++;
		size++;
	}
	return size;
}

void __vtable_copy(uintptr_t*** vtPtr) {
	uintptr_t** original = *vtPtr;
	size_t vtSize = __vtable_get_size(original) * sizeof(uintptr_t);
	uintptr_t** newVtable = (uintptr_t**) malloc(vtSize);
	memcpy(newVtable, original, vtSize);
	*vtPtr = newVtable;
}

void __vtable_hook(uintptr_t** vt, int originalOffset, uintptr_t* hook) {
	vt[originalOffset] = hook;
}

int EmeraldSword$getAttackDamage(Item* self) {
	return 10;
}

bool EmeraldSword$canDestroyInCreative(Item* self) {
	return false;
}

int EmeraldSword$getEnchantSlot(Item* self) {
	return 16;
}

int EmeraldSword$getEnchantValue(Item* self) {
	return 35;
}

bool EmeraldSword$canDestroySpecial(Item* self, const Block* block) {
	return block == Block$mBlocks[30] ? true : false;
}

float EmeraldSword$getDestroySpeed(Item* self, ItemInstance* inst, Block* block) {
	return block == Block$mBlocks[30] ? 0.4f : 0.8f;
}

void EmeraldSword$hurtEnemy(Item* self, ItemInstance* inst, Mob* mob1, Mob* mob2) {
	ItemInstance$hurtAndBreak(inst, 1, mob1);
}

void EmeraldSword$mineBlock(Item* self, ItemInstance* inst, BlockID id, int x, int y, int z, Mob* mob) {
	ItemInstance$hurtAndBreak(inst, 2, mob);
}

bool EmeraldSword$isValidRepairItem(Item* self, const ItemInstance& inst1, const ItemInstance& inst2) {
	if(inst2.item == Item$mItems[388])
		return true;
	return false;
}

static void (*_Item$registerItems)();
static void Item$registerItems() {
	_Item$registerItems();

	//EmeraldSword

	emerald_sword_ = new Item();
	Item$Item(emerald_sword_, "emerald_sword", emerald_sword - 0x100);
	Item$mItems[emerald_sword] = emerald_sword_;
	emerald_sword_->creativeCategory = 3;
	emerald_sword_->maxStackSize = 1;
	emerald_sword_->maxDamage = 1800;

	__vtable_copy((uintptr_t***) &emerald_sword_->vtable);
	__vtable_hook(emerald_sword_->vtable, 20, (uintptr_t*) &EmeraldSword$getAttackDamage);
	__vtable_hook(emerald_sword_->vtable, 26, (uintptr_t*) &EmeraldSword$canDestroyInCreative);
	__vtable_hook(emerald_sword_->vtable, 31, (uintptr_t*) &EmeraldSword$getEnchantSlot);
	__vtable_hook(emerald_sword_->vtable, 32, (uintptr_t*) &EmeraldSword$getEnchantValue);
	__vtable_hook(emerald_sword_->vtable, 16, (uintptr_t*) &EmeraldSword$canDestroySpecial);
	__vtable_hook(emerald_sword_->vtable, 42, (uintptr_t*) &EmeraldSword$hurtEnemy);
	__vtable_hook(emerald_sword_->vtable, 44, (uintptr_t*) &EmeraldSword$mineBlock);
	__vtable_hook(emerald_sword_->vtable, 30, (uintptr_t*) &EmeraldSword$isValidRepairItem);

}

static void (*_Item$initClientData)();
static void Item$initClientData() {
	_Item$initClientData();

	//EmeraldSword

	Item$setIcon(emerald_sword_, "emerald_sword", 0);
	Item$setHandEquipped(emerald_sword_);
}

static std::string (*I18n_get)(const std::string&);
static std::string _I18n_get(const std::string& key) {
	if(key == "item.emerald_sword.name") {
		return std::string{"Emerald Sword"};
	}

	return I18n_get(key);
}

static std::string (*_Common$getGameDevVersionString)(uintptr_t*);
static std::string Common$getGameDevVersionString(uintptr_t* common) {
	return "§aEmeraldTools-beta";
}

%ctor {
	MSHookFunction((void*)(0x100734d00 + _dyld_get_image_vmaddr_slide(0)), (void*)&Item$initCreativeItems, (void**)&_Item$initCreativeItems);
	MSHookFunction((void*)(0x100733348 + _dyld_get_image_vmaddr_slide(0)), (void*)&Item$registerItems, (void**)&_Item$registerItems);
	MSHookFunction((void*)(0x10074242c + _dyld_get_image_vmaddr_slide(0)), (void*)&Item$initClientData, (void**)&_Item$initClientData);
	MSHookFunction((void*)(0x10049816c + _dyld_get_image_vmaddr_slide(0)), (void*)&_I18n_get, (void**)&I18n_get);
	MSHookFunction((void*)(0x10006bc94 + _dyld_get_image_vmaddr_slide(0)), (void*)&Common$getGameDevVersionString, (void**)&_Common$getGameDevVersionString);

	Block$mBlocks = (Block**)(0x1012d1860 + _dyld_get_image_vmaddr_slide(0));

	Item$mItems = (Item**)(0x1012ae238 + _dyld_get_image_vmaddr_slide(0));
	Item$Item = (Item*(*)(Item*, const std::string&, short))(0x10074689c + _dyld_get_image_vmaddr_slide(0));
	Item$setIcon = (Item*(*)(Item*, const std::string&, int))(0x100746b0c + _dyld_get_image_vmaddr_slide(0));
	Item$setHandEquipped = (Item*(*)(Item*))(0x100746e5c + _dyld_get_image_vmaddr_slide(0));

	Item$addCreativeItem = (void(*)(const ItemInstance&))(0x100745f10 + _dyld_get_image_vmaddr_slide(0));

	ItemInstance$ItemInstance = (ItemInstance*(*)(ItemInstance*, int, int, int))(0x100756c70 + _dyld_get_image_vmaddr_slide(0));
	ItemInstance$hurtAndBreak = (void(*)(ItemInstance*, int, Mob*))(0x100758114 + _dyld_get_image_vmaddr_slide(0));
	ItemInstance$getId = (int(*)(ItemInstance*))(0x10075700c + _dyld_get_image_vmaddr_slide(0));
}