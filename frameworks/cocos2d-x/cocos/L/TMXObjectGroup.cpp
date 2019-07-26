/**
 *	@file	TMXObjectGroup.cpp
 *	@date	2018/01/25
 *
 * 	@author lujun
 *	Contact:(QQ:495904500)
 *	
 *	@brief	
 */

#include "TMXObjectGroup.h"

L::TMXObjectGroup::TMXObjectGroup():
	_offset(Vec2::ZERO)
{}

L::TMXObjectGroup::~TMXObjectGroup(){
	CCLOGINFO("deallocing TMXObjectGroup: %p", this);
}

void L::TMXObjectGroup::parseObjectGroup(xml_node<> *node) {
	CCASSERT(node && !strcmp(node->name(), "objectgroup"), "TMXObjectGroup: invalid node");

	{
		xml_attribute<> *attr = nullptr;
		attr = node->first_attribute("name");
		if (attr) {
			_name = attr->value();
		}
		attr = node->first_attribute("offsetx");
		if (attr) {
			_offset.x = std::atoi(attr->value());
		}
		attr = node->first_attribute("offsety");
		if (attr) {
			_offset.y = std::atoi(attr->value());
		}
	}

	xml_node<> *propsnode = node->first_node("properties");
	if (propsnode) {
		for (xml_node<> *propnode = propsnode->first_node("property"); propnode;
			propnode = propnode->next_sibling("property")) {
			_properties.emplace(propnode->first_attribute("name")->value(),
				propnode->first_attribute("value")->value());
		}
	}

	// Ω‚Œˆ∂‘œÛ
	for (xml_node<> *objnode = node->first_node("object"); objnode;
		objnode = objnode->next_sibling("object")) {
		TMXObject *object = new (std::nothrow) TMXObject();
		object->parseObject(objnode);
		_objects.pushBack(object);
		object->release();
	}
}
